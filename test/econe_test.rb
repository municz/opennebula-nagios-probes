$: << File.expand_path("..", __FILE__) + "/../lib"

require 'rubygems'

require 'test/unit'
require 'vcr'
require 'webmock'

require 'nagios-probe'
require 'log4r'
require 'ostruct'

require 'OpenNebulaEconeProbe'

include Log4r

WebMock.disable_net_connect! :allow => "localhost"

VCR.config do |c|
  c.cassette_library_dir = 'fixtures/cassettes/econe'
  c.stub_with :webmock
end

class EconeProbeVCRTest < Test::Unit::TestCase

  def setup
    @options = OpenStruct.new

    @options.protocol = :http
    @options.hostname = "localhost"
    @options.port     = 4568
    @options.path     = "/"
    @options.username = "oneadmin"
    @options.password = "onepass"

    @logger = Logger.new 'TestLogger'
  end

  def teardown
    ## Nothing really
  end

  def test_econe_critical_no_resources

    probe = OpenNebulaEconeProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid EC2 communication
    VCR.use_cassette('econe_critical_no_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_econe_critical_existing_resources

    #resources should not have an effect on check_crit results
    @options.storage = ["ami-00000016","ami-00000026"]
    @options.compute = ["i-145"]

    probe = OpenNebulaEconeProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid EC2 communication
    VCR.use_cassette('econe_critical_existing_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_econe_critical_nonexisting_resources

    #resources should not have an effect on check_crit results
    @options.network = ["15","9"]
    @options.storage = ["126","6"]
    @options.compute = ["4"]

    probe = OpenNebulaEconeProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid EC2 communication
    VCR.use_cassette('econe_critical_nonexisting_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_econe_warning_no_resources

    probe = OpenNebulaEconeProbe.new(@options)
    probe.logger = @logger

    # use of the VCR cassette should not affect the result
    VCR.use_cassette('econe_warning_no_resources') do
      assert_equal(false, probe.check_warn)
    end

    # without a cassette, this should not affect the result
    assert_equal(false, probe.check_warn)

  end

  def test_econe_warning_existing_resources

    @options.storage = ["ami-00000016","ami-00000026"]
    @options.compute = ["i-145"]

    probe = OpenNebulaEconeProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid EC2 communication
    VCR.use_cassette('econe_warning_existing_resources') do
      assert_equal(false, probe.check_warn)
    end

    # without a cassette the probe should report warning state
    assert_equal(true, probe.check_warn)

  end

  def test_econe_warning_nonexisting_resources

    @options.network = ["15","9"]
    @options.storage = ["126","6"]
    @options.compute = ["4"]

    probe = OpenNebulaEconeProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid EC2 communication
    VCR.use_cassette('econe_warning_nonexisting_resources') do
      assert_equal(true, probe.check_warn)
    end

    # without a cassette the probe should report warning state
    assert_equal(true, probe.check_warn)

  end
end
