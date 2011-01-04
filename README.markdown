# Geocode Service

Provides a minimalistic web service to map IPs to countries from a local MySQL database generated from data available from maxmind.com. Uses Sinatra and MySQL. Inspired by this article: http://jcole.us/blog/archives/2007/11/24/on-efficiently-geo-referencing-ips-with-maxmind-geoip-and-mysql-gis/

## Usage:

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

## Why ?

* fast
* avoids external dependencies, but reusable across multiple apps

## TODO

* add authentication ?