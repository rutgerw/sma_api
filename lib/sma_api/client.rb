# frozen_string_literal: true

module SmaApi
  # Client for reading SMA Inverter
  class Client
    def initialize(host:, password:, sid: nil)
      @host = host
      @password = password
      @client = Http.new(host: host, password: password, sid: sid)
    end

    def sid
      @client.sid
    end

    def destroy_session
      @client.destroy_session
    end

    def get_values(keys)
      result = @client.post('/dyn/getValues.json', { destDev: [], keys: keys })
      return nil unless result['result']

      keys.each_with_object({}) do |k, h|
        h[k] = scalar_value(result['result'].first[1][k])
      end
    end

    def get_fs(path)
      result = @client.post('/dyn/getFS.json', { destDev: [], path: path })

      result['result'].first[1][path].map do |f|
        type = f.key?('f') ? 'f' : 'd'
        {
          name: f['d'] || f['f'],
          type: type,
          last_modified: Time.at(f['tm']),
          size: f['s']
        }
      end
    end

    def object_metadata
      @client.post('/data/ObjectMetadata_Istl.json')
    end

    private

    def scalar_value(value)
      value['1'].first['val']
    end
  end
end
