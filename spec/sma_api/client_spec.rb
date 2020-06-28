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

    context 'optional parameters', :vcr do
      describe 'sid' do
        let(:sid) { 'some session id' }

        subject { described_class.new host: host, password: password, sid: sid }

        it 'passes sid to http client' do
          expect(SmaApi::Http).to receive(:new).with(host: host, password: password, sid: sid)

          subject
        end
      end
    end
  end

  describe '#sid' do
    subject { client.sid }

    before do
      allow_any_instance_of(SmaApi::Http).to receive(:sid).and_return('6UBJRT24Yog4xR2C')
    end

    it { is_expected.to match(/\w{16}/) }
  end

  describe '#destroy_session' do
    before do
      allow_any_instance_of(SmaApi::Http).to receive(:destroy_session)
    end

    it 'calls SmaApi::Http.destroy_session' do
      expect_any_instance_of(SmaApi::Http).to receive(:destroy_session)
      client.destroy_session
    end
  end

  describe '#get_values' do
    let(:client_response) do
      {
        'result' => {
          '0199-B32F8CCE' => {
            '6100_40263F00' => {
              '1' => [{ 'val' => 865 }]
            },
            '6400_00260100' => {
              '1' => [{ 'val' => 836_990 }]
            }
          }
        }
      }
    end
    let(:keys) { %w[6100_40263F00 6400_00260100] }
    let(:result) do
      {
        '6100_40263F00' => 865,
        '6400_00260100' => 836_990
      }
    end

    before do
      allow_any_instance_of(SmaApi::Http)
        .to receive(:post)
        .with('/dyn/getValues.json', { destDev: [], keys: keys })
        .and_return(client_response)
    end

    subject { client.get_values keys }

    it { is_expected.to eq(result) }
  end

  describe '#object_metadata' do
    let(:first_result) do
      %w[Prio TagId TagIdEvtMsg]
    end
    let(:client_response) do
      {
        "6180_08419000": {
          'Prio' => 2,
          'TagId' => 814,
          'TagIdEvtMsg' => 10_003,
          'DataFrmt' => 18,
          'Typ' => 1,
          'WriteLevel' => 5,
          'TagHier' => [
            830,
            309,
            3409
          ]
        },
        '6180_08414D00' => {
          'Prio' => 2,
          'TagId' => 240,
          'TagIdEvtMsg' => 11_177,
          'DataFrmt' => 18,
          'Typ' => 1,
          'WriteLevel' => 5,
          'TagHier' => [
            830,
            309,
            46
          ]
        }
      }
    end

    before do
      allow_any_instance_of(SmaApi::Http)
        .to receive(:post)
        .with('/data/ObjectMetadata_Istl.json')
        .and_return(client_response)
    end

    subject { client.object_metadata.first[1].keys }

    it { is_expected.to include(*first_result) }
  end
end
