# Clone Gareth via Git
class gareth::git(
	$origin = 'origin',
	$repository = 'https://github.com/dantman/gareth.git',
	$branch = 'master',
) {

	package { 'git':
		ensure => latest,
	}

	file { '/vagrant/gareth':
		ensure => 'directory',
		owner  => 'vagrant',
		mode   => '0775',
		group  => 'vagrant',
	}

	gitclone { 'clone-gareth':
		path   => '/vagrant/gareth',
		branch => $branch,
		origin => $origin,
		url    => $repository,
	}

	exec { 'gareth-vendor-submodule':
		cwd     => '/vagrant',
		command => "git submodule update --init vendor/",
		onlyif  => "git submodule status vendor/ | grep '+\\|-'",
	}

	File['/vagrant/gareth'] -> Package['git']
	Package['git'] -> Gitclone['clone-gareth']
	Package['git'] -> Exec['gareth-vendor-submodule']

}
