require 'test/unit'
require '../lib/riskbase_client'
require 'json'


class RiskbaseTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @private_key = ''
    @riskbase_key = ''
    @capy_data = ''
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Unit test cases
  def test_evaluate_invalid_private_key
    client = RiskbaseClient.new(@private_key)
    assert_equal RiskbaseResult::INVALID_PRIVATE_KEY,
                 client.evaluate(@riskbase_key, @capy_data)['result']
  end

  def test_evaluate_invalid_riskbase_key
    @private_key = 'not_empty'
    client = RiskbaseClient.new(@private_key)
    assert_equal RiskbaseResult::INVALID_RISKBASE_KEY,
                 client.evaluate(@riskbase_key, @capy_data)['result']
  end

  def test_evaluate_timeout
    @private_key = 'not_empty'
    @riskbase_key = 'not_empty'
    @capy_data = 'not_empty'
    @timeout = 0.001
    client = RiskbaseClient.new(@private_key, @timeout)
    assert_equal RiskbaseResult::TIMEOUT,
                 client.evaluate(@riskbase_key, @capy_data)['result']
  end
end
