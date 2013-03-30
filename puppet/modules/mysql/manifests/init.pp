# MySQL class. Also provisions ~/.my.cnf for convinience.
class mysql( $password = 'vagrant' ) {

	package { 'mysql-server':
		ensure => latest,
	}

	service { 'mysql':
		ensure     => running,
		hasrestart => true,
	}

	exec { 'set-mysql-password':
		unless  => "mysqladmin -u root -p\"${password}\" status",
		command => "mysqladmin -u root password \"${password}\"",
	}

	Package['mysql-server'] -> Service['mysql']
	Service['mysql'] -> Exec['set-mysql-password']

	file {
		'/home/vagrant/.my.cnf':
			ensure  => file,
			owner   => 'vagrant',
			group   => 'vagrant',
			mode    => '0600',
			replace => no,
			content => template('mysql/my.cnf.erb');
	}

	# Dummy that depends on mysql setup being complete
	exec { 'dummy-mysql-setup': command => "/bin/true" }
	Exec['set-mysql-password'] -> Exec['dummy-mysql-setup']
	File['/home/vagrant/.my.cnf'] -> Exec['dummy-mysql-setup']

}
