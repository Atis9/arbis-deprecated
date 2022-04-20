require 'sqlite3'
require 'pp'

class WordGenerator
  def initialize(filename)
    @database = SQLite3::Database.new(filename)
  end

  def generate
    sql = 'select first, second, third from three_gram_words where first = ?'

    words = @database.execute(sql, '__BEGIN__').sample

    until words.flatten.include?('__END__')
      words << @database.execute(sql, words.pop).sample

      words = words.flatten
    end

    words
  end
end

word_gen = WordGenerator.new('word.db')

serif = word_gen.generate
serif.shift
serif.pop(2)

pp serif.join
