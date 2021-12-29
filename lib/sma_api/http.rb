# frozen_string_literal: true

require 'json'
require 'net/http'

module SmaApi
  # Net::HTTP wrapper for the SMA Inverter web interface
  class Http
    def initialize(host:, password:, sid: nil)
      @host = host
      @password = password
      @sid = sid || ''
    end

    # Perform a HTTP POST.
    #
    # @param url [String] URL. It should start with a '/'
    # @param payload [Hash] The payload that will be used in the post
    # @return [Hash] The response
    def post(url, payload = {})
      create_session if @sid.empty?

      response = JSON.parse(http.post(url_with_sid(url), payload.to_json).body)

      return response unless response.key? 'err'

      raise SmaApi::Error, "Error #{response['err']} during request" unless response['err'] == 401

      create_session
      post(url, payload)
    end

    # Download the file specified by url and store it in a file on the local file system.
    #
    # @param url [String] URL without /fs prefix. It should start with a '/'
    # @param path [String] Path of the local file
    def download(url, path)
      create_session if @sid.empty?

      file = File.open(path, 'wb')

      begin
        res = retrieve_file(url)

        file.write(res.body)
      ensure
        file.close
      end
    end

    # Creates a session using the supplied password
    #
    # @raise [SmaApi::Error] Creating session failed, for example if the password is wrong
    # @return [String] the session id that will be used in subsequent requests.
    def create_session
      payload = {
        right: 'usr', pass: @password
      }
      result = JSON.parse(http.post('/dyn/login.json', payload.to_json).body).fetch('result', {})

      raise SmaApi::Error, 'Creating session failed' unless result['sid']

      @sid = result['sid']
    end

    # The current session id. If empty, it will create a new session
    #
    # @return [String] the session id that will be used in subsequent requests.
    def sid
      create_session if @sid.empty?

      @sid
    end

    # Logout and clear the session. This is the same as using Logout from the web interface
    #
    # @return [String] An empty session id
    def destroy_session
      post('/dyn/logout.json', {})

      @sid = ''
    end

    private

    def url_with_sid(url)
      url + "?sid=#{@sid}"
    end

    def retrieve_file(url)
      res = http.get("/fs#{url_with_sid(url)}")

      unless res.code == '200'
        # Try again because invalid sid does not result in a 401
        create_session
        res = http.get("/fs#{url_with_sid(url)}")

        raise "Error retrieving file (#{res.code} #{res.message})" unless res.code == '200'
      end

      res
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
