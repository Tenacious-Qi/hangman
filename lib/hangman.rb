# frozen_string_literal: true

# when initialized, generate random word
# controls saving and loading
# on load, allow option to open one of saved games
class Game
  def initialize
    @dictionary = Dictionary.new
    @display = Display.new(@dictionary)
    @player = Player.new(@dictionary, @display)
    puts winning_word
    @player.make_a_guess
  end

  def winning_word
    @dictionary.winning_word
  end

  def save
    @player.save_game
  end

  def load
    @player.load_game
  end

end

# generates a random word from a .txt file
class Dictionary
  attr_reader :winning_word

  def initialize
    @winning_word = generate_random_word
  end

  def playable_words
    File.open('./5desk.txt', 'r') do |file|
      words = file.readlines.map { |word| word.tr("\r\n", '') }
      words_to_use = words.select do |word|
        word.length > 4 && word.length < 13
      end
      words_to_use
    end
  end

  def generate_random_word
    random_idx = (rand * playable_words.length).floor
    playable_words[random_idx].downcase
  end
end

# controls display of letters and also
# count = @dictionary.winning_word.length
# if number of guesses from Player == count, game over. 
# else, continue (until loop?)
class Display
  attr_reader :progress

  def initialize(dictionary)
    @dictionary = dictionary
    dashes = @dictionary.winning_word.length
    @progress = Array.new(dashes) { |dash| +'_' }
  end
end

# can make a guess
# also has option to save the game
class Player
  def initialize(dictionary, display)
    @dictionary = dictionary
    @display = display
    @correct_guess = false
  end

  def make_a_guess
    until @correct_guess
      print "please guess a letter: "
      letter = gets.chomp.downcase.strip
      @display.progress.each_with_index do |space, index|
        if @dictionary.winning_word[index] == letter
          @display.progress[index] = letter
        end
      end
      @display.progress.each { |place| print "#{place} " }; puts
      check_for_win
    end
  end

  def check_for_win
    if @display.progress == @dictionary.winning_word.split('')
      @correct_guess = true
      puts "you win!"
      prompt_to_play_again
    end
  end

  def prompt_to_play_again
    print "would you like to play again? enter Y or N: "
    answer = gets.chomp.upcase.strip
    answer == 'Y' ? Game.new : exit
  end

  # def load_game
  # end

  # def save_game
  # end
end

Game.new
