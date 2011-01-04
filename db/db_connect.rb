require 'yaml'
db_config = YAML.load(IO.read("db/database.yml"))
$db = Mysql2::Client.new(symbolize_keys(db_config[ENV['RACK_ENV']]))