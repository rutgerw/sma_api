# frozen_string_literal: true

module SmaApi
  # Client for reading SMA Inverter
  class Client
    def initialize(host:, password:)
      @host = host
      @password = password
    end
  end
end
