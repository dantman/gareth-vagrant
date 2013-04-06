Gareth Vagrant
==============
**Gareth Vagrant** provides a Vagrant based development environment for the [Gareth][] code review system.

All of Gareth's dependencies reside in a VM letting you get quickly setup with the STOMP Server, Database server, gevent, gunicorn server, and other dependencies Gareth needs without needing to install and configure them on your host computer.

## Prerequisites
You'll need to install [Vagrant][] and [VirtualBox][] (>= 4.1).

**IMPORTANT**: You must enable hardware virtualization (VT-x or AMD-V).  This is often a BIOS setting. If you don't do that, you'll probably get an error in the last step of the installation, 'vagrant up'. You can verify this by trying to launch the VM from the VirtualBox GUI. If an error message appears that says something about "VT-X", you need to reboot the host machine and enable the BIOS setting that allows hardware virtualization.

## Installation
```bash
git clone https://github.com/dantman/gareth-vagrant.git
cd ./gareth-vagrant
vagrant up
```

It'll take some time, because it'll need to fetch the base precise64 box if you don't already have it. Once it's done, you should be able to browse to [http://localhost:8080/](http://localhost:8080/) and see a Gareth install, served by the guest VM, which is running Ubuntu Precise 64-bit.

The Gareth credentials are:

* Username: admin
* Password: vagrant

The MySQL root credentials are:

* Username: root
* Password: vagrant

To SSH into your VM, simply type `vagrant ssh`.

## Commands within the vm 
`mysql` can be used to interact directly with the database without needing any extra args.

If you `cd /var/lib/gareth/core` Gareth's `./manage.py` commands will be available.

`sudo supervisorctl` will let you interact with supervisord afnd allow you to start, stop, restart, and tail the Apollo STOMP server, Gunicorn webserver running Gareth, and Gareth's taskrunner.

`sass` is also available so from within `/var/lib/gareth/core` you can run `sass --watch garethweb/public --poll` to begin polling for .scss changes.

## License
The Gareth Vagrant repo is licensed under the [MIT License][], please see the `LICENSE` file.

This repo contains a few files that come from other codebases made by other developers. Currently these files are all also MIT licensed but the copyright is owned by others. The copyright owner and license for these will be noted inside of the individual file.

Please also remember that the Gareth repository automatically cloned when running `vagrant up` is under completely different license terms.

  [Gareth]: http://gareth-review.com
  [Vagrant]: http://vagrantup.com/v1/docs/getting-started/index.html
  [VirtualBox]: https://www.virtualbox.org/wiki/Downloads
  [MIT License]: http://opensource.org/licenses/MIT
