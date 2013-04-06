# Provides small enhancements to the shell, such as color prompt.
class misc {

	include virtualbox

	file { '/etc/profile.d/color.sh':
		ensure => file,
		mode   => '0755',
		source => 'puppet:///modules/misc/color.sh',
	}

	# Small, nifty, useful things
	package { [ 'ack-grep', 'htop', 'curl', 'tree' ]:
		ensure => present,
	}

	file { '/home/vagrant/.bash_aliases':
		ensure => present,
		mode   => '0755',
		source => 'puppet:///modules/misc/bash_aliases',
	}

}
