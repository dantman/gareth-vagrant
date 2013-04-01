class gareth::apollo {

	include java

	exec { 'apache-apollo-extract':
		creates => "/usr/local/share/apache-apollo/bin/apollo",
		command => "mkdir /usr/local/share/apache-apollo; cd /usr/local/share/apache-apollo; tar --strip-components=1 -xzf /vagrant/vendor/apache-apollo-1.6-unix-distro.tar.gz",
	}

	exec { 'apache-apollo-createbroker':
		creates => "/var/lib/apache-apollo/",
		command => "/usr/local/share/apache-apollo/bin/apollo create /var/lib/apache-apollo",
	}

	user { 'apollo':
		ensure => 'present',
		gid    => 'apollo',
		system => true,
	}

	group { 'apollo':
		ensure => 'present',
		system => true,
	}

	$writable_dirs = [
		'/var/lib/apache-apollo/data',
		'/var/lib/apache-apollo/log',
		'/var/lib/apache-apollo/tmp',
	]

	file { [$writable_dirs]:
		ensure => 'directory',
		owner  => 'apollo',
		group  => 'apollo',
		require => Exec['apache-apollo-createbroker'],
		before => File['/etc/supervisor/conf.d/gareth.conf'],
	}

	file {
		# @fixme Modifications to these should trigger broker restart
		'/var/lib/apache-apollo/etc/apollo.xml':
			ensure => 'file',
			source => 'puppet:///modules/gareth/apollo.xml',
			require => Exec['apache-apollo-createbroker'],
			before => File['/etc/supervisor/conf.d/gareth.conf'];
		'/var/lib/apache-apollo/etc/users.properties':
			ensure => 'file',
			content => "admin=vagrant\n",
			require => Exec['apache-apollo-createbroker'],
			before => File['/etc/supervisor/conf.d/gareth.conf'];
	}

	# /var/lib/apache-apollo/bin/apollo-broker run

	Exec['gareth-vendor-submodule'] -> Exec['apache-apollo-extract']
	Exec['apache-apollo-extract'] -> Exec['apache-apollo-createbroker']
	Package['openjdk-6-jre'] -> Exec['apache-apollo-createbroker']
	Exec['apache-apollo-extract'] -> Exec['apache-apollo-createbroker']

	Exec['apache-apollo-createbroker'] -> File['/etc/supervisor/conf.d/gareth.conf']

}
