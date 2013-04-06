# Copyright (C) 2013 Michael Grosser <michael@grosser.it>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Based on https://github.com/grosser/parallel/blob/master/lib/parallel.rb

class Cpu
	def self.count
		@processor_count ||= case RbConfig::CONFIG['host_os']
		when /darwin9/
			`hwprefs cpu_count`.to_i
		when /darwin/
			(`which hwprefs` != '' ? `hwprefs thread_count` : `sysctl -n hw.ncpu`).to_i
		when /linux|cygwin/
			`grep -c processor /proc/cpuinfo`.to_i
		when /(open|free)bsd/
			`sysctl -n hw.ncpu`.to_i
		when /mswin|mingw/
			require 'win32ole'
			wmi = WIN32OLE.connect("winmgmts://")
			cpu = wmi.ExecQuery("select NumberOfLogicalProcessors from Win32_Processor")
			cpu.to_enum.first.NumberOfLogicalProcessors
		when /solaris2/
			`psrinfo -p`.to_i # this is physical cpus afaik
		else
			1
		end
	end
end