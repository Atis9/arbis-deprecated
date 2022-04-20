module Bot
  class User
    attr_reader :rest, :stream, :info, :log

    def initialize(token)
      @rest = Twitter::REST::Client.new(token)
      @stream = Twitter::Streaming::Client.new(token)
      @info = @rest.verify_credentials
      @plugin = []

      @log = Logger.new(OPTS['log-file'])
      @log.progname = @info.screen_name
    end

    def activate
      standalone

      loop do
        begin
          streaming
        rescue Exception => e
          @log.warn("[Exception]\n\t#{e}\n\t#{e.backtrace.join("\n\t")}")
          @log.warn('[System] UserStream が切断されました。再接続します。')
        end
      end
    end

    def add_plugin(filename)
      @plugin << Plugin.new(self, filename).event
      @log.debug("[System] Load: #{@plugin.last[:name]}")
    end

    private
    def standalone
      @plugin.each do |p|
        p[:blk].call if p[:type] == :standalone
      end
    end

    def streaming
      @stream.user do |obj|
        @plugin.each do |p|
          Thread.start do
            begin
              p[:blk].call(obj) if p[:type] == :streaming
            rescue OptionParser::InvalidOption
              # ignored
            end
          end
        end
      end
    end
  end
end
