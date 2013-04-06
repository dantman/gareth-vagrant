# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant config
Vagrant.configure("2") do |config|

	config.vm.hostname = 'gareth-vagrant'
	config.package.name = 'gareth.box'

    # Note: If you rely on Vagrant to retrieve the box, it will not verify
    # SSL certificates. If this concerns you, you can retrieve the file using
    # another tool that implements SSL properly:
    #   $ vagrant box add precise-cloud /path/to/file/precise.box
	config.vm.box = 'precise-cloud'
	config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'

	# Use a private network to hide the box from the external network
	config.vm.network :private_network,
		ip: '10.251.196.53'

	config.vm.network :forwarded_port,
		guest: 8080,
		host: 8080,
		id: 'http',
		auto_correct: true

	# If we ever make gareth function properly as more of a library we'll move
	# it to perhaps /usr/local/lib/gareth or maybe a python path?
	config.vm.synced_folder "gareth", "/var/lib/gareth/core",
		id: 'gareth',
		owner: 'vagrant',
		group: 'vagrant',
		extra: 'dmode=775,fmode=775',
		create: true

	# Repos are in /var
	config.vm.synced_folder "repos", "/var/lib/gareth/repos",
		id: 'repos',
		owner: 'www-data',
		group: 'www-data',
		extra: 'dmode=775,fmode=775',
		create: true

	# Silence 'stdin: is not a tty' error on Puppet run
	config.vm.provision :shell do |s|
		s.inline = 'sed -i -e "s/^mesg n/tty -s \&\& mesg n/" /root/.profile'
	end

	# Provision the VM with puppet
	config.vm.provision :puppet do |puppet|
		puppet.module_path = 'puppet/modules'
		puppet.manifests_path = 'puppet/manifests'
		puppet.manifest_file = 'site.pp'
		puppet.options = [
			'--verbose',
			# Output a LOT of grey debug lines detailing what puppet is doing 
			# '--debug',
			# Output traces when there's an error in puppet code
			# (eg: When our custom Gitclone type is broken ;) )
			# '--trace',
			# Generate .dot files on puppet relationships inside:
			# /var/lib/puppet/state/graphs
			# May require some extra tweaks to function
			# '--graph',
		].join(' ')
	end

	# Restart the taskrunner from a provisioner. For some reason it looks like supervisord
	# starts the taskrunner before shared folders are setup. At which point things fail since
	# ./manage.py is not available on the system yet.
	config.vm.provision :shell do |s|
		s.inline = 'sudo supervisorctl restart taskrunner'
	end

end
