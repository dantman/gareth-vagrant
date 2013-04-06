# Clone Gareth via Git
class gareth::git(
	$origin = 'origin',
	$repository = 'https://github.com/dantman/gareth.git',
	$branch = 'master',
) {

	exec { 'add-git-core-ppa':
		command => 'add-apt-repository --yes ppa:git-core/ppa && apt-get update',
		creates => '/etc/apt/sources.list.d/git-core-ppa-precise.list',
	}

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
	Exec['add-git-core-ppa'] -> Package['git']
	Package['git'] -> Gitclone['clone-gareth']
	Package['git'] -> Exec['gareth-vendor-submodule']

}
