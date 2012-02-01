require 'optparse'
require 'ostruct'

class OptparseNagiosProbe

  VERSION = 0.99

  def self.parse(args)

    options = OpenStruct.new

    options.debug = false
    options.one_host = "localhost"
    options.one_port = 4567
    options.one_proto = :http
    options.timeout = 60

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: check_opennebula_[one|occi|econe].rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("--[no-]debug", "Run with debugging options") do |debug|
        options.debug = debug
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

      opts.on("--protocol [http|https]", [:http, :https], "Protocol to use") do |proto|
        options.one_proto = proto
      end

      opts.on("--timeout [SECONDS]", Integer, "Timeout time in seconds") do |timeout|
        options.timeout = timeout
      end

      opts.separator ""
      opts.separator "Common options:"

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

    mandatory = [:one_user, :one_pass]
    options_hash = options.marshal_dump

    missing = mandatory.select{ |param| options_hash[param].nil? }
    if not missing.empty?
      raise Exception.new("Missing required arguments #{missing.join(', ')}")
    end

    options

  end

end