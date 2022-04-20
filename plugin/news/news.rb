require_relative 'rss_parser'
require 'sqlite3'
require 'pp'

class News
  CREATE_TABLE_SQL = <<-EOS.freeze
    create table news (
      link text primary key,
      title text,
      text text
    );
  EOS

  def initialize(filename)
    filename = File.expand_path("../#{filename}", __FILE__)
    @database = load_database(filename)
    @database.results_as_hash = true
  end

  def load_database(filename)
    if File.exist?(filename)
      SQLite3::Database.new(filename)
    else
      SQLite3::Database.new(filename).execute(CREATE_TABLE_SQL)
      SQLite3::Database.new(filename)
    end
  end

  def add_news(news)
    if @database.execute(
        'select link from news where link = ?',
        news[:link]).empty?
      @database.execute('insert into news values (?, ?, ?)', news[:link], news[:title], news[:text])
    end
  end
end

if $PROGRAM_NAME == __FILE__
  rp = RSSParser.new
  news = News.new('news.db')

  YAML.load_file(File.expand_path('../../news/rss_list.yml', __FILE__)).each do |rss|
    news_list = rp.parse(rss['uri'], rss['xpath'])

    news_list.each do |n|
      news.add_news(n)
    end
  end
end
