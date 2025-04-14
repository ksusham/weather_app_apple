require 'rails_helper'
require 'webmock/rspec'

RSpec.describe LocationService do
  describe '.fetch_lat_long' do
    let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
    let(:mock_response) do
      [
        {
          "lat" => "37.4224764",
          "lon" => "-122.0842499",
          "display_name" => "1600, Amphitheatre Parkway, Mountain View, CA",
          "address" => {
            "postcode" => "94043"
          }
        }
      ]
    end

    before do
      stub_request(:get, /nominatim.openstreetmap.org/).to_return(
        status: 200,
        body: mock_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'returns correct lat/long/zip/display_name hash' do
      result = described_class.fetch_lat_long(address)
      expect(result).to include(
        lat: "37.4224764",
        long: "-122.0842499",
        zip: "94043"
      )
    end

    context 'when the API returns no results' do
      before do
        stub_request(:get, /nominatim.openstreetmap.org/).to_return(
          status: 200,
          body: [].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it 'returns nil' do
        result = described_class.fetch_lat_long(address)
        expect(result).to be_nil
      end
    end
  end
end
