require 'net/http'
require 'uri'
require 'openssl'
require 'json'


class RiskbaseResult
  SUCCESS = 'success'
  INVALID_PARAMETERS = 'invalid-parameters'
  INCORRECT_PARAMETERS = 'incorrect-parameters'
  INVALID_IP_ADDRESS = 'invalid-ip-address'
  INVALID_PRIVATE_KEY = 'invalid-privatekey'
  INVALID_RISKBASE_KEY = 'invalid-riskbase-key'
  INVALID_USERNAME = 'invalid-username'
  INSUFFICIENT_DATA = 'insufficient-data'
  SERVER_ERROR = 'server-error'
  UNKNOWN_ERROR = 'unknown-error'
  TIMEOUT = 'timeout-error'
end


class RiskbaseClient
  def initialize(capy_privatekey, timeout = 3)
    @capy_privatekey, @timeout = capy_privatekey, timeout

    @evaluation_results = {
        'success': RiskbaseResult::SUCCESS,
        'invalid-parameters': RiskbaseResult::INVALID_PARAMETERS,
        'incorrect-parameters': RiskbaseResult::INCORRECT_PARAMETERS,
        'invalid-ip-address': RiskbaseResult::INVALID_IP_ADDRESS,
        'invalid-privatekey': RiskbaseResult::INVALID_PRIVATE_KEY,
        'invalid-riskbase-key': RiskbaseResult::INVALID_RISKBASE_KEY,
        'invalid-username': RiskbaseResult::INVALID_USERNAME,
        'insufficient-data': RiskbaseResult::INSUFFICIENT_DATA,
        'server-error': RiskbaseResult::SERVER_ERROR,
        'unknown-error': RiskbaseResult::UNKNOWN_ERROR
    }

    @url = 'https://jp.api.capy.me/riskbase/riskbases/%{riskbase_key}/evaluate'
  end

  def evaluate(riskbase_key, capy_data)
    if @capy_privatekey.empty?
      return {'result' => @evaluation_results[:'invalid-privatekey']}
    end

    if riskbase_key.empty?
      return {'result' => @evaluation_results[:'invalid-riskbase-key']}
    end

    uri = URI.parse(@url % {'riskbase_key': riskbase_key})

    params = {
        capy_privatekey: @capy_privatekey,
        riskbase_key: riskbase_key,
        capy_data: capy_data
    }

    begin
      https = Net::HTTP.new(uri.host, uri.port)
      https.read_timeout = @timeout
      https.use_ssl = uri.scheme == 'https'
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data(params)

      content = https.request(request).body

      json_object = JSON.parse(content)

      if @evaluation_results.values.include? json_object['result']
        return json_object
      end

      return {'result' => @evaluation_results[:'unknown-error']}
    rescue Timeout::Error
      return {'result' => RiskbaseResult::TIMEOUT}
    rescue
      return {'result' => @evaluation_results[:'unknown-error']}
    end
  end
end
