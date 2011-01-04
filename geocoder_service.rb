require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default)
require 'utils'
configure do
  require 'db/db_connect'
  require 'geocoder'
end

class GeocodeService < Sinatra::Base
  get '/country_code_from_ip/:ip' do
    country = GeoCoder.country_code_from_ip params[:ip]
    if country.nil? || country == ""
      response.status = 404
    end
    country
  end
  
end