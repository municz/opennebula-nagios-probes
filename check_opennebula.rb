#!/usr/bin/env ruby

###########################################################################
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
###########################################################################

#
$: << File.expand_path("..", __FILE__)

#
require 'rubygems'
require 'bundler/setup'

#
require 'nagios-probe'
require 'log4r'

#
require 'lib/OpenNebulaOnedProbe'
require 'lib/OpenNebulaOcciProbe'
require 'lib/OpenNebulaEconeProbe'
require 'lib/OptparseNagiosProbe'

#
include Log4r

#
begin

  options = OptparseNagiosProbe.parse(ARGV)

  case options.service
    when :oned
      probe = OpenNebulaOnedProbe.new(options)
    when :occi
      probe = OpenNebulaOcciProbe.new(options)
    when :econe
      probe = OpenNebulaEconeProbe.new(options)
    else
      raise Exception.new("This probe cannot check the specified service")
  end

  logger = Logger.new 'OpenNebulaProbe'
  logger.outputters = Outputter.stdout
  logger.level = ERROR unless options.debug
  probe.logger = logger

  probe.run

rescue Exception => e

  puts "Unknown: " + e.message
  exit Nagios::UNKNOWN

end

#
puts probe.message
exit probe.retval
