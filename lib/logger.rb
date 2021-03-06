module Bot
  class Logger < Logger
    LEVEL = {
        'fatal' => FATAL,
        'error' => ERROR,
        'warn' => WARN,
        'info' => INFO,
        'debug' => DEBUG
    }.freeze

    def initialize(logdev, shift_age = 0, shift_size = 1048576)
      super

      @level = LEVEL[OPTS['log-level']]
      @formatter = proc { |sev, date, name, msg| "[#{date}] #{sev} -- #{name}: #{msg}\n" }
    end

    def stdout?(file)
      file == STDOUT || file == '/dev/stdout'
    end
  end
end
