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
require "bundler/setup"
require 'lib/nagios-probe.rb'

#
class OpenNebulaOnedProbe < Nagios::Probe

  #
  def exec
    puts "Getting a response from the ONED server"
  end

  #
  def check_crit
    false
  end

  #
  def check_warn
    false
  end

  #
  def crit_message
    "Things are bad"
  end

  #
  def warn_message
    "Things aren't going well"
  end

  #
  def ok_message
    "Nothing to see here"
  end
end

#
begin
  options = {} # constructor accepts a single optional param that is assigned to @opts
  probe = OpenNebulaOnedProbe.new(options)
  probe.run
rescue Exception => e
  puts "Unknown: " + e
  exit Nagios::UNKNOWN
end

#
puts probe.message
exit probe.retval
