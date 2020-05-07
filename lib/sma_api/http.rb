require 'json'

module SmaApi
  class Http
    attr_accessor :token

    def initialize(host:, password:)
      @host = host
      @password = password
      @token = ''
    end

    def post(url, payload = {})
      with_valid_user(url, payload)
    end

    def create_session
      payload = {
        right: 'usr', pass: @password
      }
      result = JSON.parse(http.post('/dyn/login.json', payload.to_json).body).fetch('result',{})

      raise SmaApi::Error.new "Creating session failed" unless result['sid']

      @token = result['sid']
    end

    def destroy_session
      with_valid_user('/dyn/logout.json', {})

      @token = ''
    end

    private

    def with_valid_user(url, payload)
      create_session if @token.empty?

      url_token = url + "?sid=#{@token}"
      response = JSON.parse(http.post(url_token, payload.to_json).body)

      return response unless response.key? 'err'

      if response['err'] == 401
        login
        with_valid_user(url, payload)
      else
        raise SmaApi::Error.new "Error #{response['err']} during request"
      end
    end

    def http
      @http ||= configure_http_client
    end

    def configure_http_client
      client =  Net::HTTP.new(@host, 443)
      client.use_ssl = true
      client.verify_mode = OpenSSL::SSL::VERIFY_NONE

      client
    end
  end
end
