module Bot
  class Controller
    def initialize
      token = YAML.load_file(File.expand_path('../../config/twitter.yml', __FILE__))
      plugin_files = Dir.glob(File.expand_path('../../plugin/*.rb', __FILE__))

      activate_user(token, plugin_files)
    end

    def activate_all
      @user.join
    end

    private

    def activate_user(token, plugin_files)
      token.each do |t|
        @user = Thread.new do
          u = User.new(t)

          plugin_files.each do |f|
            u.add_plugin(f)
          end

          u.activate
        end
      end
    end
  end
end
