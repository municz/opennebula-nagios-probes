$: << File.expand_path("..", __FILE__) + "/../lib"

require 'rubygems'

require 'test/unit'
require 'vcr'
require 'webmock'

require 'nagios-probe'
require 'log4r'
require 'ostruct'

require 'OpenNebulaOnedProbe'

include Log4r

WebMock.disable_net_connect! :allow => "localhost"

VCR.config do |c|
  c.cassette_library_dir = 'fixtures/cassettes/oned'
  c.stub_with :webmock
end

class OnedProbeVCRTest < Test::Unit::TestCase

  def setup
    options = OpenStruct.new
    options.protocol = :http
    options.hostname = "localhost"
    options.port     = 2633
    options.path     = "/RPC2"
    options.username = "oneadmin"
    options.password = "onepass"

    @probe = OpenNebulaOnedProbe.new(options)
    @probe.logger = Logger.new 'TestLogger'
  end

  def teardown
    ## Nothing really
  end

  def test_oned_critical_no_resources

    # use VCR cassette to simulate valid XMLRPC2 communication
    VCR.use_cassette('oned_critical_no_resources') do
      assert_equal(false, @probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, @probe.check_crit)

  end
end
