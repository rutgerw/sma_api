# frozen_string_literal: true

RSpec.describe SmaApi::Http do
  let(:host) { ENV.fetch('SMA_API_HOST', nil) }
  let(:client) do
    described_class.new(host: host, password: ENV.fetch('SMA_API_WEB_PASSWORD', nil))
  end

  describe '.new' do
    subject { client }

    context 'required parameters' do
      describe 'host' do
        subject { described_class.new(password: 'pw') }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error ArgumentError
        end
      end

      describe 'password' do
        subject { described_class.new(host: '0.0.0.0') }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end

    context 'optional parameters', :vcr do
      describe 'sid' do
        let(:sid) do
          client = described_class.new(host: host, password: ENV.fetch('SMA_API_WEB_PASSWORD', nil))
          client.post('/dyn/getValues.json', { destDev: [], keys: ['6100_40263F00'] })

          client.sid
        end

        it 'uses sid in initialize' do
          client = described_class.new(host: host,
                                       password: ENV.fetch('SMA_API_WEB_PASSWORD', nil), sid: sid)
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
      subject { described_class.new(host: host, password: 123).create_session }

      it 'raises SmaApi::Error' do
        expect { subject }.to raise_error(SmaApi::Error)
      end
    end
  end

  describe '#post', :vcr do
    after { client.destroy_session }

    subject { client.post('/dyn/getValues.json', { destDev: [], keys: ['6100_40263F00'] }) }

    it { is_expected.to have_key('result') }
  end

  describe '#download', :vcr do
    let(:url) { '/DIAGNOSE/EVENTS/2020/EV200417.ZIP' }
    let(:target) { 'somezip.zip' }

    after do
      client.destroy_session
      File.delete(target)
    end

    context 'when file exists' do
      context 'and session is valid' do
        subject { File.size(target) }

        before { client.download(url, target) }

        it { is_expected.to eq(1437) }
      end

      context 'and session is initially invalid' do
        let(:sid) { 'vNjAqDzglpugpDT3' }
        let(:client) do
          described_class.new(host: host, password: ENV.fetch('SMA_API_WEB_PASSWORD', nil),
                              sid: sid)
        end

        subject { File.size(target) }

        before { client.download(url, target) }

        it { is_expected.to eq(1437) }
      end
    end

    context 'when file does not exists' do
      let(:url) { '/none_existent' }

      subject { client.download(url, target) }

      it 'raises RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#destroy_session', :vcr do
    subject { client.sid }

    before { client.destroy_session }

    it 'clears @sid instance variable' do
      expect(client.instance_eval { @sid }).to eq ''
    end
  end
end
