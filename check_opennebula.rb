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
$: << File.expand_path("..", __FILE__) + '/lib'
$: << File.expand_path("..", __FILE__) + '/lib/oca'

#
require 'rubygems'
require 'bundler/setup'

#
require 'nagios-probe'
require 'AWS'
require 'occi'
require 'log4r'
require 'optparse'
require 'ostruct'

require 'OpenNebula'

#
include OpenNebula
include Log4r

#
require 'OpenNebulaOnedProbe'
require 'OpenNebulaOcciProbe'
require 'OpenNebulaEconeProbe'
require 'OptparseNagiosProbe'

#
begin

  options = OptparseNagiosProbe.parse(ARGV)

  case options.service
    when :oned
      probe = OpenNebulaOnedProbe.new(options)
      logger = Logger.new 'OpenNebulaOnedProbe'
    when :occi
      probe = OpenNebulaOcciProbe.new(options)
      logger = Logger.new 'OpenNebulaOcciProbe'
    when :econe
      probe = OpenNebulaEconeProbe.new(options)
      logger = Logger.new 'OpenNebulaEconeProbe'
    else
      raise Exception.new("This probe cannot check the specified service")
  end

  logger.outputters = Outputter.stderr
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
