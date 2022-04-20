require 'json'
require 'uri'
require 'net/http'
require 'pp'

BASE_URL = 'http://weather.livedoor.com/forecast/webservice/json/v1'.freeze
CITY_LIST = YAML.load_file(File.expand_path('../plugin/weather/city_list.yml', __FILE__)).freeze

def weather(obj, city_name)
  CITY_LIST.each do |list|
    if list['city'] == city_name
      tweet = "@#{obj.user.screen_name}\n#{get_weather(list['id'])}"

      twitter.update(tweet, :in_reply_to_status_id => obj.id)

      break
    end
  end
end

def get_weather(id)
  uri = URI.parse("#{BASE_URL}?city=#{id}")
  json = JSON.parse(Net::HTTP.get(uri))

  <<-EOS
#{json['title']}
#{json['link']}
[#{json['forecasts'][0]['dateLabel']}]
天気: #{json['forecasts'][0]['telop']}
最高気温: #{json['forecasts'][0]['temperature']['max']['celsius'] + '℃' if json['forecasts'][0]['temperature']['max']}
最低気温: #{json['forecasts'][0]['temperature']['min']['celsius'] + '℃' if json['forecasts'][0]['temperature']['min']}
[#{json['forecasts'][1]['dateLabel']}]
天気: #{json['forecasts'][1]['telop']}
最高気温: #{json['forecasts'][1]['temperature']['max']['celsius'] + '℃' if json['forecasts'][0]['temperature']['max']}
最低気温: #{json['forecasts'][1]['temperature']['min']['celsius'] + '℃' if json['forecasts'][0]['temperature']['min']}
  EOS
end

create_plugin('Weather', :streaming) do |obj|
  if allowed?(obj)
    opt = OptionParser.new do |opt|
      opt.on('-w CITY_NAME', '--weather CITY_NAME') {|city_name| weather(obj, city_name)}
      opt.on('--天気 CITY_NAME') {|city_name| weather(obj, city_name)}
      opt.on('--天気予報 CITY_NAME') {|city_name| weather(obj, city_name)}
    end

    opt.parse(obj.text.split)
  end
end
