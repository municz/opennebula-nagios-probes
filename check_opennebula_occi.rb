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
require 'nagios-probe'
require "occi"

#
class OpenNebulaOcciProbe < Nagios::Probe

  #
  def check_crit

    connection = Occi::Client.new(
        :host     => @opts[:occi_host],
        :port     => @opts[:occi_port],
        :scheme   => "https",
        :user     => @opts[:occi_user],
        :password => @opts[:occi_password]
    )

    puts connection.network.all

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
  options = {:occi_host => "", :occi_port => 9443, :occi_user => "", :occi_password => ""}
  probe = OpenNebulaOcciProbe.new(options)
  probe.run
rescue Exception => e
  puts "Unknown error: " + e.class.to_s + " saying '" + e.message + "'"
  exit Nagios::UNKNOWN
end

#
puts probe.message
exit probe.retval
