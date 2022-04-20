module Bot
  class Plugin
    attr_reader :event

    def initialize(user, filename)
      @user = user

      self.instance_eval(File.read(filename))
    end

    def create_plugin(name, type, &blk)
      @event = {name: name, type: type, blk: blk}
    end

    def twitter
      @user.rest
    end

    def stream
      @user.stream
    end

    def log
      @user.log
    end

    def screen_name
      @user.info.screen_name
    end

    def timestamp
      Time.now.strftime('%F %H:%M:%S.%L')
    end

    def allowed?(obj)
      reply?(obj) && !own_tweet?(obj)
    end

    def tweet?(obj)
      obj.is_a?(Twitter::Tweet)
    end

    def own_tweet?(obj)
      tweet?(obj) && obj.user.screen_name == screen_name
    end

    def reply?(obj)
      tweet?(obj) && obj.in_reply_to_screen_name == screen_name
    end
  end
end
