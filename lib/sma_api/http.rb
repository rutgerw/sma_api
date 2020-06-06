# frozen_string_literal: true

require 'json'
require 'net/http'

module SmaApi
  # Http wrapper
  class Http
    def initialize(host:, password:, sid: nil)
      @host = host
      @password = password
      @sid = sid || ''
    end

    def post(url, payload = {})
      with_valid_user(url, payload)
    end

    def create_session
      payload = {
        right: 'usr', pass: @password
      }
      result = JSON.parse(http.post('/dyn/login.json', payload.to_json).body).fetch('result', {})

      raise SmaApi::Error, 'Creating session failed' unless result['sid']

      @sid = result['sid']
    end

    def sid
      create_session if @sid.empty?

      @sid
    end

    def destroy_session
      with_valid_user('/dyn/logout.json', {})

      @sid = ''
    end

    private

    def with_valid_user(url, payload)
      create_session if @sid.empty?

      url_with_sid = url + "?sid=#{@sid}"

      response = JSON.parse(http.post(url_with_sid, payload.to_json).body)

      return response unless response.key? 'err'

      if response['err'] == 401
        create_session
        with_valid_user(url, payload)
      else
        raise SmaApi::Error, "Error #{response['err']} during request"
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
