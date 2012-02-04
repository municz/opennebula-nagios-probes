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
require 'lib/OpenNebulaOnedProbe'
require 'lib/OpenNebulaOcciProbe'
require 'lib/OpenNebulaEconeProbe'
require 'lib/OptparseNagiosProbe'
require 'nagios-probe'

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

  probe.run

rescue Exception => e

  puts "Unknown: " + e.message
  exit Nagios::UNKNOWN

end

#
puts probe.message
exit probe.retval
