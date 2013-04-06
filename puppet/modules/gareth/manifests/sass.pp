class gareth::sass {

	package { 'sass':
		ensure => present,
		provider => gem,
		require => File['/etc/gemrc'],
	}

	# We start sass --watch from supervisor so we need sass before we add our supervisor setup
	# Package['sass'] -> File['/etc/supervisor/conf.d/gareth.conf']

}
