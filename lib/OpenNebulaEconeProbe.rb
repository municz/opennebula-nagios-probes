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

#
class OpenNebulaEconeProbe < Nagios::Probe

  attr_writer :logger

  #
  def check_crit

    @logger.info "Checking for basic connectivity at " + @opts.protocol.to_s + "://" + @opts.hostname + ":" + @opts.port.to_s + @opts.path

    connection = AWS::EC2::Base.new(
        :access_key_id     => @opts.username,
        :secret_access_key => @opts.password,
        :server            => @opts.hostname,
        :port              => @opts.port,
        :path              => @opts.path,
        :use_ssl           => @opts.protocol == :https
    )

    begin
      connection.describe_images
      connection.describe_instances
    rescue Exception => e
      @logger.error "Failed to check connectivity: " + e.message
      return true
    end

    false
  end

  #
  def check_warn

    @logger.info "Checking for resource availability at " + @opts.protocol.to_s + "://" + @opts.hostname + ":" + @opts.port.to_s + @opts.path

    connection = AWS::EC2::Base.new(
        :access_key_id     => @opts.username,
        :secret_access_key => @opts.password,
        :server            => @opts.hostname,
        :port              => @opts.port,
        :path              => @opts.path,
        :use_ssl           => @opts.protocol == :https
    )

    begin
      # iterate over given resources
      @logger.info "Not looking for networks, since it is not supported by OpenNebula's ECONE server'"  unless @opts.network.nil?

      unless @opts.compute.nil?
        @logger.info "Looking for compute instances: " + @opts.compute.inspect
        result = connection.describe_instances
        @logger.debug result

        unless result.nil? || result["instancesSet"].nil?
          @opts.compute.each do |instance_to_look_for|
            found = false

            result["instancesSet"]["item"].each do |instance_found|
              if instance_to_look_for == instance_found["instanceId"]
                found = true
              end
            end

            raise Exception.new("Instance " + instance_to_look_for + " not found") unless found
          end
        end

      end

      unless @opts.storage.nil?
        @logger.info "Looking for storage volumes: " + @opts.storage.inspect
        result = connection.describe_images
        @logger.debug result

        unless result.nil? || result["imagesSet"].nil?
          @opts.storage.each do |image_to_look_for|
            found = false

            result["imagesSet"]["item"].each do |image_found|
              if image_to_look_for == image_found["imageId"]
                found = true
              end
            end

            raise Exception.new("Image " + image_to_look_for + " not found") unless found
          end
        end
      end
    rescue Exception => e
      @logger.error "Failed to check resource availability: " + e.message
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