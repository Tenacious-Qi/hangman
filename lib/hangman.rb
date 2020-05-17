# frozen_string_literal: true

require 'colorize'

# when initialized, generate random word
# controls saving and loading
# on load, allow option to open one of saved games
class Game
  def initialize
    @dictionary = Dictionary.new
    @display = Display.new(@dictionary)
    @hangman = Hangman.new(@dictionary, @display)
    @hangman.show_welcome_message
    @hangman.play
  end

  def winning_word
    @dictionary.winning_word
  end

  def save
    @hangman.save_game
  end

  def load
    @hangman.load_game
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

# controls display of letters and dashes
class Display
  attr_reader :progress

  def initialize(dictionary)
    @dictionary = dictionary
    dashes = @dictionary.winning_word.length
    @progress = Array.new(dashes) { +'_' }
  end
end

# can make a guess
# also has option to save the game
class Hangman
  def initialize(dictionary, display)
    @dictionary = dictionary
    @display = display
    @letter_guess = ''
    @correct_guess = false
    @incorrect_guesses = []
    @num_of_guesses = 0
    @allowed_guesses = @dictionary.winning_word.length * 2
  end

  def show_welcome_message
    puts <<-HEREDOC

        Welcome to Hangman!

        A secret word has been generated at random.
        Try to guess the letters of the secret word.
        If your letter guess is correct, 
        game will show where that letter occurs in the word.
        You will only have a few tries before the man is hanged! 

        Good luck!

    HEREDOC
  end

  def play
    until @correct_guess || @num_of_guesses == @allowed_guesses
      prompt_for_letter
      @display.progress.each_with_index do |_space, index|
        if @dictionary.winning_word[index] == @letter_guess
          @display.progress[index] = @letter_guess
        end
      end
      check_win_increment_guesses
    end
  end

  def prompt_for_letter
    display_progress
    print "\nplease guess a letter: "
    @letter_guess = gets.chomp.downcase.strip
    until @letter_guess.match?(/^[a-z]$/)
      print "\nplease guess a single letter, a thru z: "
      @letter_guess = gets.chomp.downcase.strip
    end
    print '=' * 50
  end

  def display_progress
    puts
    print 'word --> '
    @display.progress.each { |place| print "#{place} ".colorize(:cyan) }
    puts
  end

  def check_win_increment_guesses
    puts
    @num_of_guesses += 1
    check_for_incorrect_guesses
    check_for_win
    puts "remaining guesses: #{@allowed_guesses - @num_of_guesses}"
  end

  def check_for_incorrect_guesses
    display_incorrect unless @dictionary.winning_word.include?(@letter_guess)
  end

  def display_incorrect
    unless @incorrect_guesses.include?(@letter_guess)
      @incorrect_guesses << @letter_guess
    end
    puts "#{@letter_guess} = incorrect".colorize(:red)
    puts "not included: #{@incorrect_guesses}"
  end

  def check_for_win
    if @display.progress == @dictionary.winning_word.split('')
      @correct_guess = true
      puts "\nYou win!"
      puts "Winning word: #{@dictionary.winning_word.colorize(:cyan)}"
      prompt_to_play_again
    elsif @num_of_guesses == @allowed_guesses
      puts "\nSorry, you lose."
      puts "Winning word: #{@dictionary.winning_word.colorize(:cyan)}"
      prompt_to_play_again
    end
  end

  def prompt_to_play_again
    print "\nWould you like to play again? enter Y or N: ".colorize(:blue)
    answer = gets.chomp.upcase.strip
    until answer.match?(/^Y$|^N$/)
      print "\nplease enter Y or N: "
      answer = gets.chomp.upcase.strip
    end
    answer == 'Y' ? Game.new : exit
  end

  # def load_game
  # end

  # def save_game
  # end
end

Game.new
