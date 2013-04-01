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

	File['/vagrant/gareth'] -> Package['git'] -> Gitclone['clone-gareth']

}
