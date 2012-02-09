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

$: << File.expand_path("..", __FILE__) + "/oca"

require 'nagios-probe'
require 'OpenNebula'

#
include OpenNebula

#
class OpenNebulaOnedProbe < Nagios::Probe

  attr_writer :logger

  #
  def check_crit

    # OpenNebula credentials
    credentials = @opts.username + ":" + @opts.password

    # XML_RPC endpoint where OpenNebula is listening
    endpoint = @opts.protocol.to_s + "://" + @opts.hostname + ":" + @opts.port.to_s + "/RPC2"

    @logger.info "Checking for basic connectivity at " + endpoint

    client = Client.new(credentials, endpoint, true, @opts.timeout)

    vnet_pool = VirtualNetworkPool.new(client, -1)
    rc = vnet_pool.info
    if OpenNebula.is_error?(rc)
      @logger.error "Failed to check connectivity: " + rc.message
      return true
    end

    image_pool = ImagePool.new(client, -1)
    rc = image_pool.info
    if OpenNebula.is_error?(rc)
      @logger.error "Failed to check connectivity: " + rc.message
      return true
    end

    vm_pool = VirtualMachinePool.new(client, -1)
    rc = vm_pool.info
    if OpenNebula.is_error?(rc)
      @logger.error "Failed to check connectivity: " + rc.message
      return true
    end

    false
  end

  #
  def check_warn

    # OpenNebula credentials
    credentials = @opts.username + ":" + @opts.password

    # XML_RPC endpoint where OpenNebula is listening
    endpoint = @opts.protocol.to_s + "://" + @opts.hostname + ":" + @opts.port.to_s + "/RPC2"

    @logger.info "Checking for resource availability at " + endpoint

    # there is nothing to test in this stage
    if @opts.network.nil? && @opts.storage.nil? && @opts.compute.nil?
      @logger.debug "There are no resources to check, for details on how to specify resources see --help"
      return false
    end

    client = Client.new(credentials, endpoint, true, @opts.timeout)

    # check networks, if there are any
    if !@opts.network.nil?
      @logger.debug "Looking for networks: " + @opts.network.inspect
      vnet_pool = VirtualNetworkPool.new(client, -1)
      rc = vnet_pool.info
      if OpenNebula.is_error?(rc)
        @logger.error "Failed to check resource availability: " + rc.message
        return true
      end

      vnet_pool.each do |vnet|
        rc = vnet.info
        if OpenNebula.is_error?(rc)
          @logger.error "Failed to check resource availability: " + rc.message
          return true
        else
          @logger.debug vnet.id.to_s + " " + vnet.name
        end
      end
    end

    # check storage, if there is some
    if !@opts.storage.nil?
      @logger.debug "Looking for storage volumes: " + @opts.storage.inspect
      image_pool = ImagePool.new(client, -1)
      rc = image_pool.info
      if OpenNebula.is_error?(rc)
        @logger.error "Failed to check resource availability: " + rc.message
        return true
      end

      image_pool.each do |image|
        rc = image.info
        if OpenNebula.is_error?(rc)
          @logger.error "Failed to check resource availability: " + rc.message
          return true
        else
          @logger.debug image.id.to_s + " " + image.name
        end
      end
    end

    # check VMs, if there are any
    if !@opts.compute.nil?
      @logger.debug "Looking for compute instances: " + @opts.compute.inspect
      vm_pool = VirtualMachinePool.new(client, -1)
      rc = vm_pool.info
      if OpenNebula.is_error?(rc)
        @logger.error "Failed to check resource availability: " + rc.message
        return true
      end

      vm_pool.each do |vm|
        rc = vm.info
        if OpenNebula.is_error?(rc)
          @logger.error "Failed to check resource availability: " + rc.message
          return true
        else
          @logger.debug vm.id.to_s + " " + vm.name
        end
      end
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
