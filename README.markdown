# Geocode Service

Provides a minimalistic web service to map IPs to countries from a local MySQL database generated from data available from maxmind.com. Uses Sinatra and MySQL. Inspired by this article: http://jcole.us/blog/archives/2007/11/24/on-efficiently-geo-referencing-ips-with-maxmind-geoip-and-mysql-gis/

## Installation:

<pre>
gem i bundler
bundle install
[edit db/database.yml and create the database geocode_service]
rake load_data
[for production, set RACK_ENV accordingly:]
RACK_ENV=production rake load_data
rackup
</pre>

## Test it:

<pre>
curl http://localhost:9292/country_code_from_ip/[some ip here]
</pre>

Empty body and 404 response status means IP was not found in the database.

## Use it

A common use case might be detecting the user's language based on his location. In a Rails app you could setup a before_filter in your
application controller like this:

<pre>
  ...
  before_filter :set_locale
  ...
  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      res = geocode request.ip
      if res.body.empty?
        I18n.locale = Settings.default_locale
        Rails.logger.warn "Geocoder found no match for #{request.ip}, falling back to default locale (#{Settings.default_locale})"
      else
        # implement a method to map countries to a language
        I18n.locale = lang_from_country(res.body.downcase.to_sym)
      end
    end

  # log the error, notify hoptoad, fallback to a default locale etc..  
  rescue Timeout::Error => ex
  rescue Errno::ECONNREFUSED => ex
  end
  ...
  private
  def geocode(ip)
    url = URI.parse(Settings.geocoder.endpoint)
    req = Net::HTTP::Get.new(url.path + ip)
    Net::HTTP.new(url.host, url.port).start do |http|
     http.read_timeout = Settings.geocoder.read_timeout
     http.open_timeout = Settings.geocoder.open_timeout
     http.request req
    end
  end  
</pre>

## Why ?

* fast
* avoids external dependencies, but reusable across multiple apps

## TODO

* add authentication ?


Copyright (c) 2011 [Mihai Târnovan, Cubus Arts](http://cubus.ro "Cubus Arts"), released under the MIT license (see LICENSE)