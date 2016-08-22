require 'net/http'
require 'uri'
require 'openssl'


class AvatarResult
  SUCCESS = 0
  INCORRECT_ANSWER = 10
  INVALID_REQUEST_METHOD = 20
  INVALID_POST_PARAMETERS = 30
  INVALID_PRIVATE_KEY = 40
  INVALID_CHALLENGE_KEY = 50
  INVALID_CAPTCHA_KEY = 60
  IS_NOT_ACTIVE = 70
  UNKNOWN_ERROR = 1000
  TIMEOUT = 1001
end


class AvatarClient

  def initialize(capy_privatekey, timeout = 3)
    @uri = URI.parse('https://jp.api.capy.me/avatar/verify')

    @capy_privatekey, @timeout = capy_privatekey, timeout

    @verification_result = {
        "success": AvatarResult::SUCCESS,
        'incorrect-answer': AvatarResult::INCORRECT_ANSWER,
        'invalid-request-method': AvatarResult::INVALID_REQUEST_METHOD,
        'invalid-post-parameters': AvatarResult::INVALID_POST_PARAMETERS,
        'invalid-private-key': AvatarResult::INVALID_PRIVATE_KEY,
        'invalid-challenge-key': AvatarResult::INVALID_CHALLENGE_KEY,
        'invalid-captcha-key': AvatarResult::INVALID_CAPTCHA_KEY,
        'is-not-active': AvatarResult::IS_NOT_ACTIVE,
        'unknown-error': AvatarResult::UNKNOWN_ERROR
    }
  end

  def verify(capy_challengekey, capy_answer)
    if @capy_privatekey.empty?
      return @verification_result[:'invalid-private-key']
    end

    if capy_challengekey.empty?
      return @verification_result[:'invalid-challenge-key']
    end

    if capy_answer.empty?
      return @verification_result[:'incorrect-answer']
    end

    params = {
        capy_challengekey: capy_challengekey,
        capy_privatekey: @capy_privatekey,
        capy_answer: capy_answer
    }

    begin
      https = Net::HTTP.new(@uri.host, @uri.port)
      https.read_timeout = @timeout
      https.use_ssl = @uri.scheme == 'https'
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(@uri.path)
      request.set_form_data(params)

      response = https.request(request)
      content = response.body

      @verification_result.each_key do |k|
        if content.include? k.to_s
          begin
            return @verification_result[k]
          rescue
            return @verification_result[:'unknown-error']
          end
        end
      end

      return @verification_result[:'unknown-error']
    rescue Timeout::Error
      return AvatarResult::TIMEOUT
    rescue
      return @verification_result[:'unknown-error']
    end
  end
end
