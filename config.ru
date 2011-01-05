require 'rubygems'
require 'bundler'
Bundler.require
require './geocoder_service'

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)


run GeocodeService