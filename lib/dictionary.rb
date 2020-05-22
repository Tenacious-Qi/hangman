# frozen_string_literal: true

# generates a random word of specified length from a .txt file
class Dictionary
  attr_accessor :winning_word

  def initialize
    @winning_word = generate_random_word
  end

  def playable_words
    File.open('lib/5desk.txt', 'r') do |file|
      words = file.readlines.map(&:strip)
      words_to_use = words.select do |word|
        word.length.between?(5, 12)
      end
      words_to_use
    end
  end

  def generate_random_word
    random_idx = (rand * playable_words.length).floor
    playable_words[random_idx].downcase
  end
end
