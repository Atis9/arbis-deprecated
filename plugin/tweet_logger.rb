create_plugin('TweetLogger', :streaming) do |obj|
  log.info("[@#{obj.user.screen_name}]\n\t#{obj.text}") if reply?(obj)
  log.info("[@#{obj.user.screen_name}]\n\t#{obj.text}") if own_tweet?(obj)
end
