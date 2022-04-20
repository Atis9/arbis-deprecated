require_relative 'lib/requirements'

OPTS = ARGV.getopts('', 'log-file:/dev/stdout', 'log-level:info').freeze

Signal.trap(:TERM) do
  puts 'Terminating...'
  exit
end

bot = Bot::Controller.new
bot.activate_all
