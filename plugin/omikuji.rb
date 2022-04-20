def omikuji(obj)
  fortune = %w(大吉 吉 中吉 小吉 半吉 末吉 末小吉 平 凶 小凶 半凶 末凶 大凶).freeze

  tweet = "@#{obj.user.screen_name} #{fortune.sample}"
  twitter.update(tweet, :in_reply_to_status_id => obj.id)
end

create_plugin('Omikuji', :streaming) do |obj|
  if allowed?(obj)
    opt = OptionParser.new do |opt|
      opt.on('-o', '--omikuji') {omikuji(obj)}
      opt.on('--おみくじ') {omikuji(obj)}
    end

    opt.parse(obj.text.split)
  end
end
