#!/usr/bin/env ruby

####################################################
##
##
##
##
##
##
####################################################

#
$: << File.expand_path("..", __FILE__)

#
require 'rubygems'
require 'bundler/setup'
require 'lib/OptparseNagiosProbe'
require 'lib/OpenNebulaOneProbe'
require 'nagios-probe'

#
begin

  options = OptparseNagiosProbe.parse(ARGV)

  probe = OpenNebulaOneProbe.new(options)
  probe.run

rescue Exception => e

  puts "Unknown: " + e.message
  exit Nagios::UNKNOWN

end

#
puts probe.message
exit probe.retval
