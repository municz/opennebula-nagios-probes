require 'nagios-probe'
require "occi"

#
class OpenNebulaOcciProbe < Nagios::Probe

  #
  def check_crit

    begin

      connection = Occi::Client.new(
          :host     => @opts.one_host,
          :port     => @opts.one_port,
          :scheme   => @opts.proto,
          :user     => @opts.one_user,
          :password => @opts.one_pass
      )

      connection.network.all
      connection.compute.all
      connection.storage.all

    rescue Exception => e
      return true
    end

    false
  end

  #
  def check_warn

    begin

      connection = Occi::Client.new(
          :host     => @opts.one_host,
          :port     => @opts.one_port,
          :scheme   => @opts.proto,
          :user     => @opts.one_user,
          :password => @opts.one_pass
      )

      connection.network.find 1
      connection.compute.find 1
      connection.storage.find 1

    rescue Exception => e
      return true
    end

    false
  end

  #
  def crit_message
    "Failed to establish connection with the remote server"
  end

  #
  def warn_message
    "Failed to query specified remote resources"
  end

  #
  def ok_message
    "Remote resources successfully queried"
  end
end