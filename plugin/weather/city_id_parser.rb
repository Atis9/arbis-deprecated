require 'pp'
require 'yaml'
require 'rexml/document'
require 'open-uri'
require 'net/http'

uri = URI.parse('http://weather.livedoor.com/forecast/rss/primary_area.xml')
xml = open(uri)
doc = REXML::Document.new(xml)

city_id = []

REXML::XPath.match(doc, 'rss/channel/ldWeather:source/pref/city').each do |obj|
  city_id << {'city' => obj['title'], 'id' => obj['id']}
end

pp city_id

open(File.expand_path('../city_list.yml', __FILE__), 'w') do |f|
  YAML.dump(city_id, f)
end
