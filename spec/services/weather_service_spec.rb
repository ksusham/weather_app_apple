require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherService do
  describe ".call_weather_api" do
    let(:location) do
      {
        lat: 37.669022,
        long: -121.8642436,
        display_name: "Pleasanton, CA"
      }
    end

    let(:api_response) do
      {
        "current" => {
          "temperature_2m" => 18.5,
          "wind_speed_10m" => 10.0,
          "time" => "2025-04-12T12:00"
        },
        "hourly" => {
          "time" => [ "2025-04-12T00:00", "2025-04-12T01:00", "2025-04-12T02:00" ],
          "temperature_2m" => [ 15.1, 14.8, 14.3 ],
          "relative_humidity_2m" => [ 80, 82, 85 ],
          "wind_speed_10m" => [ 5.0, 6.5, 7.2 ]
        }
      }.to_json
    end

    before do
      stub_request(:get, /api\.open-meteo\.com/)
        .to_return(status: 200, body: api_response, headers: {})
    end

    it "returns parsed weather data" do
      result = described_class.call_weather_api(location)

      expect(result[:location]).to eq("Pleasanton, CA")
      expect(result[:temperature]).to eq(18.5)
      expect(result[:windspeed]).to eq(10.0)
      expect(result[:time]).to eq("2025-04-12T12:00")

      expect(result[:hourly_forecast]).to be_a(Hash)
      expect(result[:hourly_forecast].keys.first).to match(/\d{4}-\d{2}-\d{2}/)

      first_hour = result[:hourly_forecast].values.first.first
      expect(first_hour).to include(:time, :temperature, :humidity, :wind)
    end
  end
end
