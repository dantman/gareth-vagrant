require 'shellwords'

Puppet::Type.newtype(:gitclone) do
	@doc = "Ensures that a git repo has been cloned into a directory."

	ensurable do
		# desc "..."
		defaultto :present

		newvalue(:absent) do
			raise ArgumentError, "Repository destruction is not implemented."
		end

		aliasvalue(:false, :absent)

		newvalue(:present, :event => :repo_created) do
			cmd = [
				Puppet::Util.which('git'),
				'clone',
				'--branch', @resource[:branch],
				'--origin', @resource[:origin],
				@resource[:url],
				@resource[:path]
			]
			cmd.map! { |arg| Shellwords::shellescape arg }

			Puppet::Util.execute cmd

			return :repo_created
		end

		# Check that we can actually create anything
		def check
			basedir = File.dirname(@resource[:path])

			if ! FileTest.exists?(basedir)
				raise Puppet::Error,
				"Can not create #{@resource.title}; parent directory does not exist"
			elsif ! FileTest.directory?(basedir)
				raise Puppet::Error,
				"Can not create #{@resource.title}; #{dirname} is not a directory"
			end
		end

	end

	newparam(:path) do
		desc "The path to the directory the git repo should be cloned into. Must be fully qualified."
		isnamevar

		validate do |value|
			unless Puppet::Util.absolute_path?(value)
				fail Puppet::Error, "File paths must be fully qualified, not '#{value}'"
			end
		end

	end

	newparam(:url) do
		desc "The url of the repository to clone from."
		nodefault
	end

	newparam(:origin) do
		desc "The name that should be given to the remote we initially clone from."
		defaultto 'origin'
		newvalues(/^[^ ]+$/)
	end

	newparam(:branch) do
		desc "The branch of the repo that should be checked out on clone."
		defaultto 'master'
		newvalues(/^[^ ]+$/)
	end

	def exist?
		exists?
	end
	def exists?
		stat ? true : false
	end


	def flush
		@stat = :needs_stat
	end

	def initialize(hash)
		super
		@stat = :needs_stat
	end

	def stat
		return @stat unless @stat == :needs_stat

		@stat = begin
			::File.send(:stat, File.join(self[:path], '/.git'))
		rescue Errno::ENOENT => error
			nil
		rescue Errno::EACCES => error
			warning "Could not stat; permission denied"
			nil
		end
	end

end
