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
          :scheme   => @opts.one_proto,
          :user     => @opts.one_user,
          :password => @opts.one_pass
      )

      connection.network.all

    rescue Exception => e
      return true
    end

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