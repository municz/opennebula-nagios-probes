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
require 'rubygems'
require "bundler/setup"
require 'nagios-probe'

#
class OpenNebulaOcciProbe < Nagios::Probe

  #
  def check_crit
    false
  end

  #
  def check_warn
    false
  end

  #
  def check_ok
    true
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
  probe = OpenNebulaOcciProbe.new(options)
  probe.run
rescue Exception => e
  puts "Unknown: " + e
  exit Nagios::UNKNOWN
end

#
puts probe.message
exit probe.retval
