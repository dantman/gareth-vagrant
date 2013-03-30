# Provides small enhancements to the shell, such as color prompt.
class misc {

	file { '/etc/profile.d/color.sh':
		ensure => file,
		mode   => '0755',
		source => 'puppet:///modules/misc/color.sh',
	}

}
