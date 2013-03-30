class nginx {

	package { 'nginx':
		ensure => present,
	}

	service { 'nginx':
		ensure     => running,
		require    => Package['nginx'],
		hasrestart => true,
	}

	file { '/etc/nginx/conf.d/disable-sendfile':
		ensure  => file,
		source  => 'puppet:///modules/nginx/disable-sendfile',
		require => Package['nginx'],
		before  => Service['nginx'],
	}

	exec { 'reload-nginx':
		command     => 'service nginx reload',
		refreshonly => true,
		before      => Service['nginx'],
	}

}
