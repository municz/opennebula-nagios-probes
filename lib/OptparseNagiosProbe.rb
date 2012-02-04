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

require 'optparse'
require 'ostruct'

class OptparseNagiosProbe

  VERSION = 0.99

  def self.parse(args)

    options = OpenStruct.new

    options.debug = false
    options.one_host = "localhost"
    options.one_port = 4567
    options.proto = :http
    options.timeout = 60

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: check_opennebula_[one|occi|econe].rb [options]"

      opts.separator ""
      opts.separator "Connection options:"

      opts.on("--service [SERVICE_NAME]", [:oned, :occi, :econe], "Name of the cloud service to check") do |service|
        options.service = service
      end

      opts.on("--host [HOSTNAME]", String, "Host to be queried") do |host|
        options.one_host = host
      end

      opts.on("--port [PORT_NUMBER]", Integer, "Port to be queried") do |port|
        options.one_port = port
      end

      opts.on("--user [USERNAME]", String, "Username for authentication purposes") do |user|
        options.one_user = user
      end

      opts.on("--password [PASSWORD]", String, "Password for authentication purposes") do |pass|
        options.one_pass = pass
      end

      opts.separator ""
      opts.separator "Session options:"

      opts.on("--protocol [http|https]", [:http, :https], "Protocol to use") do |proto|
        options.proto = proto
      end

      opts.on("--timeout [SECONDS]", Integer, "Timeout time in seconds") do |timeout|
        options.timeout = timeout
      end

      opts.separator ""
      opts.separator "Service options:"

      opts.on("--check-networks [LIST_OF_IDS]", Array, "List of network IDs to check") do |network|
        options.network = network
      end

      opts.on("--check-storages [LIST_OF_IDS]", Array, "List of storage IDs to check") do |storage|
        options.storage = storage
      end

      opts.on("--check-computes [LIST_OF_IDS]", Array, "List of VM IDs to check") do |compute|
        options.compute = compute
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on("--[no-]debug", "Run with debugging options") do |debug|
        options.debug = debug
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit!
      end

      opts.on_tail("--version", "Show version") do
        puts VERSION
        exit!
      end

    end

    opts.parse!(args)

    mandatory = [:one_user, :one_pass, :service]
    options_hash = options.marshal_dump

    missing = mandatory.select{ |param| options_hash[param].nil? }
    if not missing.empty?
      raise Exception.new("Missing required arguments #{missing.join(', ')}")
    end

    options

  end

end