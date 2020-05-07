# frozen_string_literal: true

RSpec.describe SmaApi::Client do
  let(:host) { ENV['SMA_API_HOST'] }
  let(:password) { ENV['SMA_API_WEB_PASSWORD'] }
  let(:client) { described_class.new host: host, password: password }

  describe '.new' do
    subject { client }

    context 'required parameters' do
      describe 'host' do
        subject { -> { described_class.new password: 'pw' } }

        it { is_expected.to raise_error ArgumentError }
      end

      describe 'password' do
        subject { -> { described_class.new host: '0.0.0.0' } }

        it { is_expected.to raise_error ArgumentError }
      end
    end
  end

  xdescribe '#get_values' do
    let(:keys) { %w[6100_40263F00 6400_00260100] }

    subject { client.get_values keys }

    it { is_expected.to eq({}) }
  end
end
