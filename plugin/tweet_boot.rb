create_plugin('TweetBoot', :standalone) do
  twitter.update("Boot: #{timestamp}")
end
