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
require 'AWS'

#
class OpenNebulaEconeProbe < Nagios::Probe

  attr_writer :logger

  #
  def check_crit

    @logger.info "Checking for basic connectivity at " + @opts.protocol.to_s + "://" + @opts.hostname + ":" + @opts.port.to_s + @opts.path

    ec2_connection = AWS::EC2::Base.new(
        :access_key_id     => @opts.username,
        :secret_access_key => @opts.password,
        :server            => @opts.hostname,
        :port              => @opts.port,
        :path              => @opts.path,
        :use_ssl           => @opts.protocol == :https
    )

    begin
      ec2_connection.describe_images
      ec2_connection.describe_instances
    rescue Exception => e
      @logger.error "Failed to check connectivity: " + e.message
      return true
    end

    false
  end

  #
  def check_warn

    @logger.info "Checking for resource availability at " + @opts.protocol.to_s + "://" + @opts.hostname + ":" + @opts.port.to_s + @opts.path

    ec2_connection = AWS::EC2::Base.new(
        :access_key_id     => @opts.username,
        :secret_access_key => @opts.password,
        :server            => @opts.hostname,
        :port              => @opts.port,
        :path              => @opts.path,
        :use_ssl           => @opts.protocol == :https
    )

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