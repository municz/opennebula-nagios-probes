$: << File.expand_path("..", __FILE__) + "/../lib"

require 'rubygems'

require 'test/unit'
require 'vcr'
require 'webmock'

require 'nagios-probe'
require 'log4r'
require 'ostruct'

require 'OpenNebulaOcciProbe'

include Log4r

WebMock.disable_net_connect! :allow => "localhost"

VCR.config do |c|
  c.cassette_library_dir = 'fixtures/cassettes/occi'
  c.stub_with :webmock
end

class OcciProbeVCRTest < Test::Unit::TestCase

  def setup
    @options = OpenStruct.new

    @options.protocol = :http
    @options.hostname = "localhost"
    @options.port     = 4567
    @options.path     = "/"
    @options.username = "oneadmin"
    @options.password = "onepass"

    @logger = Logger.new 'TestLogger'
  end

  def teardown
    ## Nothing really
  end

  def test_occi_critical_no_resources

    probe = OpenNebulaOcciProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid OCCI communication
    VCR.use_cassette('occi_critical_no_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_occi_critical_existing_resources

    #resources should not have an effect on check_crit results
    @options.network = ["4","6"]
    @options.storage = ["16","26"]
    @options.compute = ["145"]

    probe = OpenNebulaOcciProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid OCCI communication
    VCR.use_cassette('occi_critical_existing_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_occi_critical_nonexisting_resources

    #resources should not have an effect on check_crit results
    @options.network = ["15","9"]
    @options.storage = ["126","6"]
    @options.compute = ["4"]

    probe = OpenNebulaOcciProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid OCCI communication
    VCR.use_cassette('occi_critical_nonexisting_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_occi_warning_no_resources

    probe = OpenNebulaOcciProbe.new(@options)
    probe.logger = @logger

    # use of the VCR cassette should not affect the result
    VCR.use_cassette('occi_warning_no_resources') do
      assert_equal(false, probe.check_warn)
    end

    # without a cassette, this should not affect the result
    assert_equal(false, probe.check_warn)

  end

  def test_occi_warning_existing_resources

    @options.network = ["4","6"]
    @options.storage = ["16","26"]
    @options.compute = ["145"]

    probe = OpenNebulaOcciProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid OCCI communication
    VCR.use_cassette('occi_warning_existing_resources') do
      assert_equal(false, probe.check_warn)
    end

    # without a cassette the probe should report warning state
    assert_equal(true, probe.check_warn)

  end

  def test_occi_warning_nonexisting_resources

    @options.network = ["15","9"]
    @options.storage = ["126","6"]
    @options.compute = ["4"]

    probe = OpenNebulaOcciProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid OCCI communication
    VCR.use_cassette('occi_warning_nonexisting_resources') do
      assert_equal(true, probe.check_warn)
    end

    # without a cassette the probe should report warning state
    assert_equal(true, probe.check_warn)

  end
end
