# frozen_string_literal: true

module SmaApi
  # Client for reading SMA Inverter
  class Client
    def initialize(host:, password:)
      @host = host
      @password = password
      @client = Http.new(host: host, password: password)
    end

    def get_values(keys)
      result = @client.post('/dyn/getValues.json', { destDev: [], keys: keys })
      return nil unless result['result']

      keys.inject({}) do |h,k|
        h[k] = scalar_value(result['result'].first[1][k])
        h
      end
    end

    private

    def scalar_value(v)
      v['1'].first['val']
    end
  end
end
