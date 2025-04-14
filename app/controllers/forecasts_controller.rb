class ForecastsController < ApplicationController
  def new; end

  def create
    redirect_to forecast_path(address: params[:address])
  end

  def show
    @address = params[:address]

    if @address.present?
      location = LocationService.fetch_lat_long(@address)
      if location.nil?
        @error = "Location not found. Please enter a valid U.S. address."
        return
      end
      forecast = WeatherService.fetch(location)
      @weather = forecast[:data]
      @cached = forecast[:cached]
    end
  end
end
