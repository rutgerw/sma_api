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

    def get_values(keys)
      result = @client.post('/dyn/getValues.json', { destDev: [], keys: keys })
      return nil unless result['result']

      keys.each_with_object({}) do |k, h|
        h[k] = scalar_value(result['result'].first[1][k])
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
