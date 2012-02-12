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

$: << File.expand_path("..", __FILE__) + "/../lib"
$: << File.expand_path("..", __FILE__) + "/../lib/oca"

require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'vcr'
require 'webmock'

require 'nagios-probe'
require 'log4r'
require 'ostruct'

require 'OpenNebula'

#
include OpenNebula
include Log4r

require 'OpenNebulaOnedProbe'

class OnedProbeVCRTest < Test::Unit::TestCase

  def setup

    WebMock.disable_net_connect! :allow => "localhost"

    VCR.config do |c|
      c.cassette_library_dir = 'fixtures/cassettes/oned'
      c.stub_with :webmock
    end

    @options = OpenStruct.new

    @options.protocol = :http
    @options.hostname = "localhost"
    @options.port     = 2633
    @options.path     = "/RPC2"
    @options.username = "oneadmin"
    @options.password = "onepass"

    @logger = Logger.new 'TestLogger'
  end

  def teardown
    ## Nothing really
  end

  def test_oned_critical_no_resources

    probe = OpenNebulaOnedProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid XMLRPC2 communication
    VCR.use_cassette('oned_critical_no_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_oned_critical_existing_resources

    #resources should not have an effect on check_crit results
    @options.network = ["4","6"]
    @options.storage = ["16","26"]
    @options.compute = ["144"]

    probe = OpenNebulaOnedProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid XMLRPC2 communication
    VCR.use_cassette('oned_critical_existing_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_oned_critical_nonexisting_resources

    #resources should not have an effect on check_crit results
    @options.network = ["15","9"]
    @options.storage = ["126","6"]
    @options.compute = ["4"]

    probe = OpenNebulaOnedProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid XMLRPC2 communication
    VCR.use_cassette('oned_critical_nonexisting_resources') do
      assert_equal(false, probe.check_crit)
    end

    # without a cassette the probe should report critical state
    assert_equal(true, probe.check_crit)

  end

  def test_oned_warning_no_resources

    probe = OpenNebulaOnedProbe.new(@options)
    probe.logger = @logger

    # use of the VCR cassette should not affect the result
    VCR.use_cassette('oned_warning_no_resources') do
      assert_equal(false, probe.check_warn)
    end

    # without a cassette, this should not affect the result
    assert_equal(false, probe.check_warn)

  end

  def test_oned_warning_existing_resources

    @options.network = ["4","6"]
    @options.storage = ["16","26"]
    @options.compute = ["144"]

    probe = OpenNebulaOnedProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid XMLRPC2 communication
    VCR.use_cassette('oned_warning_existing_resources') do
      assert_equal(false, probe.check_warn)
    end

    # without a cassette the probe should report warning state
    assert_equal(true, probe.check_warn)

  end

  def test_oned_warning_nonexisting_resources

    @options.network = ["15","9"]
    @options.storage = ["126","6"]
    @options.compute = ["4"]

    probe = OpenNebulaOnedProbe.new(@options)
    probe.logger = @logger

    # use VCR cassette to simulate valid XMLRPC2 communication
    VCR.use_cassette('oned_warning_nonexisting_resources') do
      assert_equal(true, probe.check_warn)
    end

    # without a cassette the probe should report warning state
    assert_equal(true, probe.check_warn)

  end
end
