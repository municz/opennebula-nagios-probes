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

require 'nagios-probe'
require 'occi'

#
class OpenNebulaOcciProbe < Nagios::Probe

  attr_writer :logger

  #
  def check_crit

    @logger.debug "Checking ..."

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