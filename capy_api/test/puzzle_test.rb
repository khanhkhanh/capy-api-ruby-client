require 'test/unit'
require '../lib/puzzle_client'

class PuzzleTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @private_key = ''
    @challenge_key = ''
    @capy_answer = ''
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Unit test cases
  def test_verify_invalid_private_key
    client = PuzzleClient.new(@private_key)
    assert_equal PuzzleResult::INVALID_PRIVATE_KEY,
                 client.verify(@challenge_key, @capy_answer)
  end

  def test_verify_invalid_challenge_key
    @private_key = 'not null'
    client = PuzzleClient.new(@private_key)
    assert_equal PuzzleResult::INVALID_CHALLENGE_KEY,
                 client.verify(@challenge_key, @capy_answer)
  end

  def test_verify_incorrect_answer
    @private_key = 'not null'
    @challenge_key = 'not null'
    client = PuzzleClient.new(@private_key)
    assert_equal PuzzleResult::INCORRECT_ANSWER,
                 client.verify(@challenge_key, @capy_answer)
  end

  def test_verify_timeout
    @private_key = 'not null'
    @challenge_key = 'not null'
    @capy_answer = 'not null'
    @timeout = 0.001
    client = PuzzleClient.new(@private_key, @timeout)
    assert_equal PuzzleResult::TIMEOUT,
                 client.verify(@challenge_key, @capy_answer)
  end
end
