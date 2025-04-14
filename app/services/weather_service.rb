require "net/http"
require "uri"
require "json"

class WeatherService
  def self.fetch(location)
    key = location[:zip] ? location[:zip] : location[:display_name]
    cache_key = "weather_#{key}"
    if Rails.cache.exist?(cache_key)
      { data: Rails.cache.read(cache_key), cached: true }
    else
      weather_data = call_weather_api(location)
      Rails.cache.write(cache_key, weather_data, expires_in: 30.minutes)
      { data: weather_data, cached: false }
    end
  end

  def self.call_weather_api(location)
    # Using Open-Meteo API for weather data
    begin
      uri = URI("https://api.open-meteo.com/v1/forecast")
      uri.query = URI.encode_www_form(
        latitude: location[:lat],
        longitude: location[:long],
        current: "temperature_2m,wind_speed_10m",
        hourly: "temperature_2m,relative_humidity_2m,wind_speed_10m",
        timezone: "auto"
      )

      res = Net::HTTP.get_response(uri)

      unless res.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Weather API call failed: #{res.code} #{res.message}")
        return nil
      end

      data = JSON.parse(res.body)
      hourly_data = data["hourly"] if data["hourly"].present?
      hourly_forecast = {}

      hourly_data["time"].each_with_index do |time, i|
        next unless i.even? # every 2 hours

        time = Time.parse(time)
        date = time.strftime("%Y-%m-%d")
        hour = time.strftime("%I:%M %p")

        hourly_forecast[date] ||= []
        hourly_forecast[date] << {
          time: hour,
          temperature: hourly_data["temperature_2m"][i],
          humidity: hourly_data["relative_humidity_2m"][i],
          wind: hourly_data["wind_speed_10m"][i]
        }
      end
      {
        location: location[:display_name],
        temperature: data.dig("current", "temperature_2m"),
        windspeed: data.dig("current", "wind_speed_10m"),
        time: data.dig("current", "time"),
        hourly_forecast: hourly_forecast
      }
    rescue
      Rails.logger.error("Error in call_weather_api: #{e.message}")
      nil
    end
  end
end
