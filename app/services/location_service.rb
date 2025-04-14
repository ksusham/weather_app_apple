require "net/http"
require "uri"
require "json"

class LocationService
  def self.fetch_lat_long(address)
    uri = URI("https://nominatim.openstreetmap.org/search")
    uri.query = URI.encode_www_form(q: address, format: "json", addressdetails: 1, countrycodes: "us")
    res = Net::HTTP.get_response(uri)

    unless res.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Location API call failed: #{res.code} #{res.message}")
      return nil
    end

    data = JSON.parse(res.body).first
    puts "Location API response: #{data.inspect}" if Rails.env.development?
    { lat: data["lat"],
      long: data["lon"],
      zip: data.dig("address", "postcode"),
      display_name: data["display_name"]
    } rescue nil
  end
end
