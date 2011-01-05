require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default)
require 'utils'
configure do
  require 'db/db_connect'
  require 'geocoder'
  connect
end

class GeocodeService < Sinatra::Base
  
  get '/country_code_from_ip/:ip' do
    country = GeoCoder.country_code_from_ip params[:ip]
    response.status = 404 if country.nil? || country == ""
    country
  end
  
end