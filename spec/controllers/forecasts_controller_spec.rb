# spec/controllers/forecasts_controller_spec.rb
require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  describe "GET #show" do
    let(:address) { "Pleasanton, CA" }
    let(:location_data) do
      {
        lat: "37.422",
        long: "-122.084",
        zip: "94566",
        display_name: "Pleasanton, CA"
      }
    end

    let(:forecast_data) do
      {
        data: { temperature: 22.5 },
        cached: false
      }
    end

    context "when address is valid" do
      before do
        allow(LocationService).to receive(:fetch_lat_long).with(address).and_return(location_data)
        allow(WeatherService).to receive(:fetch).with(location_data).and_return(forecast_data)
        get :show, params: { address: address }
      end

      it "assigns the address" do
        expect(assigns(:address)).to eq(address)
      end

      it "assigns the weather data" do
        expect(assigns(:weather)).to eq(forecast_data[:data])
      end

      it "assigns the cached flag" do
        expect(assigns(:cached)).to eq(false)
      end

      it "does not assign an error" do
        expect(assigns(:error)).to be_nil
      end
    end

    context "when location is not found" do
      before do
        allow(LocationService).to receive(:fetch_lat_long).with(address).and_return(nil)
        get :show, params: { address: address }
      end

      it "assigns an error message" do
        expect(assigns(:error)).to eq("Location not found. Please enter a valid U.S. address.")
      end
    end

    context "when address is blank" do
      before { get :show, params: { address: "" } }

      it "does not assign weather or error" do
        expect(assigns(:weather)).to be_nil
        expect(assigns(:error)).to be_nil
      end
    end
  end
end
