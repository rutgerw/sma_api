# frozen_string_literal: true

RSpec.describe SmaApi::Http do
  let(:host) { ENV['SMA_API_HOST'] }
  let(:client) do
    described_class.new(host: host, password: ENV['SMA_API_WEB_PASSWORD'])
  end

  describe '.new' do
    subject { client }

    context 'required parameters' do
      describe 'host' do
        subject { -> { described_class.new(password: 'pw') } }

        it { is_expected.to raise_error(ArgumentError) }
      end

      describe 'password' do
        subject do
          -> { described_class.new(host: '0.0.0.0') }
        end

        it { is_expected.to raise_error(ArgumentError) }
      end
    end

    context 'optional parameters', :vcr do
      describe 'sid' do
        let(:sid) do
          client = described_class.new(host: host, password: ENV['SMA_API_WEB_PASSWORD'])
          client.post('/dyn/getValues.json', { destDev: [], keys: ['6100_40263F00'] })

          client.sid
        end

        it 'uses sid in initialize' do
          client = described_class.new(host: host, password: ENV['SMA_API_WEB_PASSWORD'], sid: sid)
          client.post('/dyn/getValues.json', { destDev: [], keys: ['6100_40263F00'] })

          expect(client.sid).to eq(sid)
        end
      end
    end
  end

  describe '#create_session', :vcr do
    subject { client.create_session }

    context 'when a valid password is supplied' do
      it { is_expected.to match(/\w{16}/) }
    end

    context 'invalid password' do
      subject { -> { described_class.new(host: host, password: 123).create_session } }

      it { is_expected.to raise_error(SmaApi::Error) }
    end
  end

  describe '#post', :vcr do
    after { client.destroy_session }

    subject { client.post('/dyn/getValues.json', { destDev: [], keys: ['6100_40263F00'] }) }

    it { is_expected.to have_key('result') }
  end

  describe '#destroy_session', :vcr do
    subject { client.sid }

    before { client.destroy_session }

    it { is_expected.to be_empty }
  end
end
