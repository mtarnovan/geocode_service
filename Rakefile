require 'rake'
require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default)

ENV['RACK_ENV'] ||= 'development'

require 'utils.rb'
require 'db/db_connect.rb'

desc "Create and populate ip <-> countries database"
task :load_data do
  connect
  puts "Dropping table ip_country"
  $db.query <<-EOS
    DROP TABLE IF EXISTS ip_country;
  EOS
  
  puts "Creating table ip_country"
  $db.query <<-EOS
    CREATE TABLE ip_country
    (
      id           INT UNSIGNED  NOT NULL auto_increment,
      ip_poly      POLYGON       NOT NULL,
      ip_from      INT UNSIGNED  NOT NULL,
      ip_to        INT UNSIGNED  NOT NULL,
      country_code CHAR(2)       NOT NULL,
      PRIMARY KEY (id),
      SPATIAL INDEX (ip_poly)
    );    
  EOS
  
  data_file_path = "data/GeoIPCountryWhois.csv"
  if !File.exists? data_file_path
    url = "http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip"
    puts "Can't find #{data_file_path}, fetching from #{url}..."
    `cd data;curl -O #{url}; unzip GeoIPCountryCSV.zip; rm GeoIPCountryCSV.zip`
  end
  
  puts "Loading data"
  $db.query <<-EOS
    LOAD DATA LOCAL INFILE "#{data_file_path}"
    INTO TABLE ip_country
    FIELDS
      TERMINATED BY ","
      ENCLOSED BY "\\""
    LINES
      TERMINATED BY "\\n"
    (
      @ip_from_string, @ip_to_string,
      @ip_from, @ip_to,
      @country_code, @country_string
    )
    SET
      id      := NULL,
      ip_from := @ip_from,
      ip_to   := @ip_to,
      ip_poly := GEOMFROMWKB(POLYGON(LINESTRING(
        /* clockwise, 4 points and back to 0 */
        POINT(@ip_from, -1), /* 0, top left */
        POINT(@ip_to,   -1), /* 1, top right */
        POINT(@ip_to,    1), /* 2, bottom right */
        POINT(@ip_from,  1), /* 3, bottom left */
        POINT(@ip_from, -1)  /* 0, back to start */
      ))),
      country_code := @country_code
    ;
  EOS
  records = $db.query "SELECT COUNT(*) from ip_country", :as => :array
  puts "Done: ip_country table now has #{records.first} records"
end