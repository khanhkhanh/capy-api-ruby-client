require 'net/http'
require 'uri'
require 'openssl'
require 'json'


class BlacklistResult
  TOO_MANY_FAILURES = 'too-many-failures'
  TOO_MANY_SUCCESSES = 'too-many-successes'
  NOT_FOUND = 'not-found'
  AZURE = 'azure'
  AWS_EC2 = 'aws_ec2'
  TOR_EXIT = 'tor_exit'
  PROXY_SERVER = 'proxy_server'
  FOUND_BUT_EXPIRED = 'found-but-expired'
  IN_WHITELIST = 'in-whitelist'
  INVALID_PARAMETERS = 'invalid-parameters'
  INVALID_IP_ADDRESS = 'invalid-ip-address'
  INVALID_PRIVATE_KEY = 'invalid-private-key'
  INVALID_BLACKLIST_KEY = 'invalid-blacklist-key'
  UNKNOWN_ERROR = 'unknown-error'
  TIMEOUT = 'timeout-error'
end


class BlacklistClient
  def initialize(capy_privatekey, timeout = 3)
    @capy_privatekey, @timeout = capy_privatekey, timeout

    @evaluation_results = {
        'too-many-failures': BlacklistResult::TOO_MANY_FAILURES,
        'too-many-successes': BlacklistResult::TOO_MANY_SUCCESSES,
        'found-but-expired': BlacklistResult::FOUND_BUT_EXPIRED,
        'not-found': BlacklistResult::NOT_FOUND,
        'azure': BlacklistResult::AZURE,
        'aws_ec2': BlacklistResult::AWS_EC2,
        'tor_exit': BlacklistResult::TOR_EXIT,
        'proxy_server': BlacklistResult::PROXY_SERVER,
        'in-whitelist': BlacklistResult::IN_WHITELIST,
        'invalid-parameters': BlacklistResult::INVALID_PARAMETERS,
        'invalid-ip-address': BlacklistResult::INVALID_IP_ADDRESS,
        'invalid-private-key': BlacklistResult::INVALID_PRIVATE_KEY,
        'invalid-blacklist-key': BlacklistResult::INVALID_BLACKLIST_KEY,
        'unknown-error': BlacklistResult::UNKNOWN_ERROR
    }

    @url = 'https://jp.api.capy.me/blacklist/blacklists/%{blacklist_key}/evaluate'
  end

  def evaluate(blacklist_key, capy_ipaddress)
    if @capy_privatekey.empty?
      return {'result' => @evaluation_results[:'invalid-private-key']}
    end

    if blacklist_key.empty?
      return {'result' => @evaluation_results[:'invalid-blacklist-key']}
    end

    if capy_ipaddress.empty?
      return {'result' => @evaluation_results[:'invalid-ip-address']}
    end

    uri = URI.parse(@url % {'blacklist_key': blacklist_key})

    params = {
      capy_privatekey: @capy_privatekey,
      capy_ipaddress: capy_ipaddress
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
      return {'result' => BlacklistResult::TIMEOUT}
    rescue
      return {'result' => @evaluation_results[:'unknown-error']}
    end
  end
end
