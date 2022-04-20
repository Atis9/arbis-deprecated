require 'natto'
require 'sqlite3'
require 'pp'

class WordLearner
  CREATE_TABLE_SQL = <<-EOS.freeze
    create table three_gram_words (
      first text,
      second text,
      third text
    );
  EOS

  def initialize(filename)
    filename = File.expand_path(filename, __FILE__)
    @database = load_database(filename)
    @mecab = Natto::MeCab.new
  end

  def load_database(filename)
    if File.exist?(filename)
      SQLite3::Database.new(filename)
    else
      SQLite3::Database.new(filename).execute(CREATE_TABLE_SQL)
      SQLite3::Database.new(filename)
    end
  end

  def parse(text)
    result = []

    @mecab.parse(text) do |temp|
      result << temp.surface
    end

    result.delete_at(-1)

    result
  end

  def learn(str_ary)
    words = ['__BEGIN__', str_ary, '__END__', nil].flatten
    three_gram = words.shift(2)

    words.each do |w|
      three_gram.push(w)
      add_words(three_gram[0], three_gram[1], three_gram[2])
      three_gram.shift
    end
  end

  private

  def add_words(first, second, third)
    @database.execute('insert into three_gram_words values (?, ?, ?)', first, second, third)
  end
end

require_relative '../news/rss_parser'

wl = WordLearner.new
rp = RSSParser.new

YAML.load_file(File.expand_path('../../news/rss_list.yml', __FILE__)).each do |rss|
  news = rp.parse(rss['uri'], rss['xpath'])

  news.each do |n|
    n[:text].split("\n").each do |t|
      wl.learn(wl.parse(t.delete('　')))
    end
  end
end
