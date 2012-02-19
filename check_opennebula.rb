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

# include the probe files and a custom version of OCA
$: << File.expand_path("..", __FILE__) + '/lib'

# bundler integration and dependencies
require 'rubygems'
require 'bundler/setup'

require 'nagios-probe'
require 'log4r'
include Log4r

# include the probe classes and a custom argument parser
require 'OpenNebulaOnedProbe'
require 'OpenNebulaOcciProbe'
require 'OpenNebulaEconeProbe'
require 'OptparseNagiosProbe'

begin

  # parse the arguments (type checks, required args etc.)
  options = OptparseNagiosProbe.parse(ARGV)

  # instantiate a probe
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

  # set the logger
  logger.outputters = Outputter.stderr
  logger.level = ERROR unless options.debug
  probe.logger = logger

  # run the probe
  probe.run

rescue Exception => e

  puts "Unknown: " + e.message
  exit Nagios::UNKNOWN

end

# report the result in a nagios-compatible format
puts probe.message
exit probe.retval
