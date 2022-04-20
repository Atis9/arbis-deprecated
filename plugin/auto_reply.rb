require 'docomoru'

@docomo_api = Docomoru::Client.new(
    api_key: YAML.load_file(File.expand_path('../config/docomo_api.yml', __FILE__))['api_key']
)

def reply(obj)
  message = obj.text.delete("@#{screen_name}")
  res = @docomo_api.create_dialogue(message)

  "@#{obj.user.screen_name} #{res.body['utt']}"
end

create_plugin('AutoReply', :streaming) do |obj|
  if reply?(obj) && !obj.text.include?('-') && !own_tweet?(obj)
    twitter.update(reply(obj), :in_reply_to_status_id => obj.id)
  end
end
