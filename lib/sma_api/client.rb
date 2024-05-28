# frozen_string_literal: true

module SmaApi
  # Ruby client for communicating with SMA Inverter web interface
  class Client
    def initialize(host:, password:, sid: nil)
      @host = host
      @password = password
      @client = Http.new(host:, password:, sid:)
    end

    # The current session id. If empty, it will create a new session
    #
    # @return [String] the session id that will be used in subsequent requests.
    def sid
      @client.sid
    end

    # Logout and clear the session. This is the same as using Logout from the web interface
    #
    # @return [String] An empty session id
    def destroy_session
      @client.destroy_session
    end

    # Retrieve values specified by the keys using getValues.json endpoint.
    #
    # @param keys [Array<String>] List of keys
    # @return [Hash] Key-value pairs
    def get_values(keys)
      result = @client.post('/dyn/getValues.json', { destDev: [], keys: })
      return nil unless result['result']

      keys.each_with_object({}) do |k, h|
        h[k] = get_value(k, result)
      end
    end

    # Retrieve list of files and directories for the path.
    #
    # @return [Array] List of directories and files
    def get_fs(path)
      result = @client.post('/dyn/getFS.json', { destDev: [], path: })

      result['result'].first[1][path].map do |f|
        type = f.key?('f') ? 'f' : 'd'
        {
          name: f['d'] || f['f'],
          type:,
          last_modified: Time.at(f['tm']),
          size: f['s']
        }
      end
    end

    # Download the file specified by url and store it in a file on the local file system.
    #
    # @param url [String] URL without /fs prefix. It should start with a '/'
    # @param path [String] Path of the local file
    def download(path, target)
      @client.download(path, target)
    end

    # ObjectMetadata_Istl endpoint
    #
    # @return [Array] List of available object metadata
    def object_metadata
      @client.post('/data/ObjectMetadata_Istl.json')
    end

    private

    def get_value(requested_key, result)
      split_by_underscore = requested_key.split('_')
      if split_by_underscore.size == 3
        array_value(result, split_by_underscore[0..1].join('_'), split_by_underscore[2].to_i)
      else
        scalar_value(result['result'].first[1][requested_key])
      end
    end

    def array_value(result, result_key, position)
      result['result'].first[1][result_key]['1'][position]['val']
    end

    def scalar_value(value)
      value['1'].first['val']
    end
  end
end
