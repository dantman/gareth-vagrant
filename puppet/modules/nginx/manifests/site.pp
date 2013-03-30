# Nginx site resource type.
define nginx::site( $site = $title, $ensure = 'present', $source = undef, $content = undef ) {

	include nginx

	case $ensure {
		present: {
			if ( $content ) {
				file { "/etc/nginx/sites-available/${site}":
					ensure  => file,
					content => $content,
				}
			} elsif ( $source ) {
				file { "/etc/nginx/sites-available/${site}":
					ensure  => file,
					source => $source,
				}
			} else {
				file { "/etc/nginx/sites-available/${site}":
					ensure  => file,
				}
			}
			Package['nginx'] -> File["/etc/nginx/sites-available/${site}"]
			File["/etc/nginx/sites-available/${site}"] ~> Exec['reload-nginx']
			File["/etc/nginx/sites-available/${site}"] -> File["/etc/nginx/sites-enabled/${site}"]

			file { "/etc/nginx/sites-enabled/${site}":
				ensure => link,
				target => "/etc/nginx/sites-available/${site}",
			}

		}
		absent: {
			file { "/etc/nginx/sites-enabled/${site}":
				ensure => absent,
			}
		}
	}
	Package['nginx'] -> File["/etc/nginx/sites-enabled/${site}"]
	File["/etc/nginx/sites-enabled/${site}"] ~> Exec['reload-nginx']

}
