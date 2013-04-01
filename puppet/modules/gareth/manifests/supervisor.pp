class gareth::supervisor {

	package { 'supervisor':
		ensure => present,
	}

	service { 'supervisor': }

	exec { 'supervisor-reload':
		command => 'supervisorctl reload',
		refreshonly => true,
	}

	Package['supervisor'] -> Service['supervisor'] -> Exec['supervisor-reload']

}
