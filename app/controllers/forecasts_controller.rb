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
      puts "Location: #{location.inspect}" if Rails.env.development?
      forecast = WeatherService.fetch(location)
      puts "Forecast: #{forecast.inspect}" if Rails.env.development?
      @weather = forecast[:data]
      @cached = forecast[:cached]
    end
  end
end
