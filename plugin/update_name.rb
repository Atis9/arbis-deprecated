def update_name(obj, name)
  twitter.update_profile(name: name)

  tweet = "@#{obj.user.screen_name} 名前を「#{name}」に変更しました。"
rescue Twitter::Error::Forbidden => e
  tweet = "@#{obj.user.screen_name} #{e.message}"
ensure
  twitter.update(tweet, :in_reply_to_status_id => obj.id)
end

create_plugin('UpdateName', :streaming) do |obj|
  if allowed?(obj)
    opt = OptionParser.new do |opt|
      opt.on('-n NAME', '--name NAME') {|name| update_name(obj, name)}
    end

    opt.parse(obj.text.split)
  end
end
