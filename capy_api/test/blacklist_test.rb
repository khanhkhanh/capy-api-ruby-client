require 'test/unit'
require '../lib/blacklist_client'
require 'json'


class BlacklistTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @private_key = ''
    @blacklist_key = ''
    @capy_ipaddress = ''
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Unit test cases
  def test_evaluate_invalid_private_key
    client = BlacklistClient.new(@private_key)
    assert_equal BlacklistResult::INVALID_PRIVATE_KEY,
                 client.evaluate(@blacklist_key, @capy_ipaddress)['result']
  end

  def test_evaluate_invalid_blacklist_key
    @private_key = 'not empty'
    client = BlacklistClient.new(@private_key)
    assert_equal BlacklistResult::INVALID_BLACKLIST_KEY,
                 client.evaluate(@blacklist_key, @capy_ipaddress)['result']
  end

  def test_evaluate_invalid_ip_address
    @private_key = 'not empty'
    @blacklist_key = 'not empty'
    client = BlacklistClient.new(@private_key)
    assert_equal BlacklistResult::INVALID_IP_ADDRESS,
                 client.evaluate(@blacklist_key, @capy_ipaddress)['result']
  end

  def test_evaluate_timeout
    @private_key = 'not_empty'
    @blacklist_key = 'not_empty'
    @capy_ipaddress = 'not_empty'
    @timeout = 0.001
    client = BlacklistClient.new(@private_key, @timeout)
    assert_equal BlacklistResult::TIMEOUT,
                 client.evaluate(@blacklist_key, @capy_ipaddress)['result']
  end
end
