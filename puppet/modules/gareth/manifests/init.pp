class gareth(
	$dbname = 'gareth',
	$dbuser = 'root',
	$dbpass = 'vagrant',
) {

	class { 'mysql':
		password => $dbpass,
	}

	include git
	include python
	include supervisor
	include nginx
	include apollo
	include sass

	file {
		# Ensure the /var/lib directories Gareth is installed in and configured in exist
		'/var/lib/gareth':
			ensure  => 'directory',
			owner   => 'vagrant',
			mode    => '0775',
			group   => 'vagrant';
		'/var/lib/gareth/config':
			ensure  => 'directory',
			owner   => 'vagrant',
			mode    => '0775',
			group   => 'vagrant';
		'/var/lib/gareth/core':
			ensure  => 'directory',
			owner   => 'vagrant',
			mode    => '0775',
			group   => 'vagrant';
		'/var/lib/gareth/repos':
			ensure  => 'directory',
			owner   => 'www-data',
			mode    => '0775',
			group   => 'www-data';

		# Ensure that Gareth's manage.py is executable
		'/var/lib/gareth/core/manage.py':
			ensure  => 'file',
			owner   => 'vagrant',
			mode    => '0775',
			group   => 'vagrant';

		# Ensure that Gunicorn's run directory exists
		'/var/run/gunicorn':
			ensure  => 'directory',
			owner   => 'www-data',
			mode    => '0755',
			group   => 'www-data';

		# Ensure that Gunicorn's log directory exists
		'/var/log/gunicorn':
			ensure  => 'directory',
			owner   => 'www-data',
			mode    => '0755',
			group   => 'www-data';

		# Create a config file for Gareth
		'/var/lib/gareth/core/gareth/settings_user.py':
			ensure  => 'file',
			owner   => 'vagrant',
			mode    => '0775',
			group   => 'vagrant',
			source  => 'puppet:///modules/gareth/settings_user.py';

		# Gunicorn config for Gareth
		'/var/lib/gareth/config/gunicorn.py':
			ensure  => 'file',
			owner   => 'vagrant',
			mode    => '0775',
			group   => 'vagrant',
			source  => 'puppet:///modules/gareth/gunicorn.py';

		'/var/lib/gareth/config/db.ini':
			ensure  => 'file',
			owner   => 'vagrant',
			mode    => '0664',
			group   => 'vagrant',
			content => "[db]\nuser=${dbuser}\npass=${dbpass}\nname=${dbname}\n";

		# Supervisor config to launch Gareth
		'/etc/supervisor/conf.d/gareth.conf':
			ensure  => 'file',
			owner   => 'vagrant',
			mode    => '0664',
			group   => 'vagrant',
			source  => 'puppet:///modules/gareth/supervisor.conf';

		# Include a Gemrc file to speed up gem installations by disabling doc generation
		'/etc/gemrc':
			ensure  => 'file',
			owner   => 'root',
			mode    => '0664',
			group   => 'root',
			source  => 'puppet:///modules/gareth/gemrc';
	}

	# Gareth config file holding SECRET_KEY
	exec { 'gareth-secret_key':
		creates => '/var/lib/gareth/config/secret_key',
		command => 'python -c \'import os; print os.urandom(32).encode("hex")\' > /var/lib/gareth/config/secret_key',
	}

	nginx::site { 'default':
		ensure => absent,
	}

	# Gunicorn/Gareth nginx site
	nginx::site { 'gareth':
		ensure => 'present',
		source => 'puppet:///modules/gareth/site.conf',
	}

	$core_dir = '/var/lib/gareth/core'

	exec {
		'gareth-createdb':
			command => "mysql --defaults-file=/home/vagrant/.my.cnf -e \"CREATE DATABASE ${dbname};\"",
			unless  => "mysql --defaults-file=/home/vagrant/.my.cnf \"${dbname}\" -e status";
		'gareth-syncdb':
			cwd => $core_dir,
			command => "${core_dir}/manage.py syncdb";
		'gareth-migrate':
			cwd => $core_dir,
			command => "${core_dir}/manage.py migrate";
		'gareth-createuser':
			cwd => $core_dir,
			command => "${core_dir}/manage.py createuser -a admin vagrant",
			unless  => "mysql --defaults-file=/home/vagrant/.my.cnf gareth -B -e \"SELECT username FROM garethweb_user WHERE username = 'admin' LIMIT 1;\" | grep admin";
	
		'set-default-database':
			command => "echo 'database = \"${dbname}\"' >> /home/vagrant/.my.cnf",
			unless  => "grep 'database = \"${dbname}\"' /home/vagrant/.my.cnf";
	}


	## Dependencies

	# Gareth's config folder needs to exist before we can create the secret key
	# The rest of the config are files which will autorequire their parent folders automatically
	File['/var/lib/gareth/config'] -> Exec['gareth-secret_key']

	# Gareth needs to be cloned before we can make sure manage.py is executable
	Gitclone['clone-gareth'] -> File['/var/lib/gareth/core/manage.py']
	
	# settings_user.py requires Gareth to be cloned before it can be created
	Gitclone['clone-gareth'] -> File['/var/lib/gareth/core/gareth/settings_user.py']

	# Gunicorn config needs the various Gareth config files to be ready before it can run anything
	# @fixme Instead of using the config file we should use something like a gunicorn service instead
	#        It would also probably be cleaner for all Gunicorn stuff to depend on Gareth being fully installed
	File['/var/lib/gareth/core/gareth/settings_user.py'] -> File['/var/lib/gareth/config/gunicorn.py']
	File['/var/lib/gareth/config/db.ini'] -> File['/var/lib/gareth/config/gunicorn.py']
	Exec['gareth-secret_key'] -> File['/var/lib/gareth/config/gunicorn.py']
	# Gunicorn also needs it's run and log files
	File['/var/run/gunicorn'] -> File['/var/lib/gareth/config/gunicorn.py']
	File['/var/log/gunicorn'] -> File['/var/lib/gareth/config/gunicorn.py']
	# @todo reload gunicorn when gunicorn config changes (eg: Exec['gunicorn-reload'])

	# We need supervisor before we can add gareth's supervisor config
	Package['supervisor'] -> File['/etc/supervisor/conf.d/gareth.conf']
	# Our gareth config needs Gunicorn's config to be setup before it can execute anything
	File['/var/lib/gareth/config/gunicorn.py'] -> File['/etc/supervisor/conf.d/gareth.conf']
	# Reload supervisor when we change it's config
	File['/etc/supervisor/conf.d/gareth.conf'] ~> Exec['supervisor-reload']

	# createdb needs the defaults file setup
	Exec['dummy-mysql-setup'] -> Exec['gareth-createdb']
	# Setup syncdb to depend on all resources needed by gareth
	Exec['dummy-gareth-packages'] -> Exec['gareth-syncdb']
	Gitclone['clone-gareth'] -> Exec['gareth-syncdb']
	File['/var/lib/gareth/core/manage.py'] -> Exec['gareth-syncdb']
	File['/var/lib/gareth/core/gareth/settings_user.py'] -> Exec['gareth-syncdb']
	File['/var/lib/gareth/config/db.ini'] -> Exec['gareth-syncdb']
	Exec['gareth-secret_key'] -> Exec['gareth-syncdb']
	# Setup the order of command execution
	Exec['gareth-createdb'] -> Exec['gareth-syncdb'] -> Exec['gareth-migrate'] -> Exec['gareth-createuser']

	# We can't append the default database to .my.cnf until it exists
	File['/home/vagrant/.my.cnf'] -> Exec['set-default-database']
	# mysql will give us trouble if the default database is set before it exists
	Exec['gareth-createdb'] -> Exec['set-default-database']


}
