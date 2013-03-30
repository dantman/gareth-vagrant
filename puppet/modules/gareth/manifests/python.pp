class gareth::python {

	package { [
		'python',
		'python-dev',
		'python-pip',
		'build-essential',
		'libevent-dev',
		'libmysqlclient-dev'
	]:
		ensure => present,
	}

	package { [
		# Standard deps
		# @fixme gevent and django take a long time to install. Include some of their deps to make activity visible
		'gevent',
		'gevent-socketio',
		'gunicorn',
		'django',
		'south',
		'pytz',
		'pygments',
		'diff-match-patch',
		'stomp.py',

		# Support for MySQL
		'mysql-python'
	]:
		ensure => present,
		provider => pip,
		require => [Package["python-pip"]],
		# before => [Gitclone['clone-gareth']],
	}

	# The bundled version of distribute is too old to install mysql-python with
	package { 'distribute':
		ensure => latest,
		provider => pip,
		require => [Package["python-pip"]],
	}

	# python-dev needs python itself
	Package["python"] -> Package["python-dev"]
	# Many pip packages require build tools and python's dev headers to install
	Package["python-dev"] -> Package["python-pip"]
	Package["build-essential"] -> Package["python-pip"]

	# Gevent requires libevent-dev to work
	Package['libevent-dev'] -> Package['gevent']

	# gevent-socketio require gevent
	Package['gevent'] -> Package['gevent-socketio']

	# We need to upgrade distribute before we can install mysql-python
	Package['distribute'] -> Package['mysql-python']
	# mysql-python requires the mysql client library (and it's dev headers)
	Package['libmysqlclient-dev'] -> Package['mysql-python']

	# Create a dummy resource that requires all the packages that gareth needs to run
	exec { 'dummy-gareth-packages': command => "/bin/true" }
	Package['python'] -> Exec['dummy-gareth-packages']
	Package['gevent'] -> Exec['dummy-gareth-packages']
	Package['gevent-socketio'] -> Exec['dummy-gareth-packages']
	Package['gunicorn'] -> Exec['dummy-gareth-packages']
	Package['django'] -> Exec['dummy-gareth-packages']
	Package['south'] -> Exec['dummy-gareth-packages']
	Package['pytz'] -> Exec['dummy-gareth-packages']
	Package['pygments'] -> Exec['dummy-gareth-packages']
	Package['diff-match-patch'] -> Exec['dummy-gareth-packages']
	Package['stomp.py'] -> Exec['dummy-gareth-packages']
	Package['mysql-python'] -> Exec['dummy-gareth-packages']

}
