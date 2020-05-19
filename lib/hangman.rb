require 'colorize'
require 'yaml'
# frozen_string_literal = true
$loaded_game = false

# when initialized, generate random word
# controls saving and loading
# on load, allow option to open one of saved games
class Game
  attr_accessor :dictionary, :display

  def initialize(dictionary, display, hangman)
    @dictionary = dictionary
    @display = display
    @hangman = hangman
    unless $loaded_game
      show_welcome_message
      initialize_other_classes
      prompt_to_load_game
    end
    @hangman.play
  end

  def initialize_other_classes
    @dictionary = Dictionary.new
    @display = Display.new(@dictionary)
    @hangman = Hangman.new(@dictionary, @display)
  end

  def prompt_to_load_game
    puts "\nWould you like to load a saved game?"
    print "\nEnter 'Y' to load a saved game or 'N' to play a new game: "
    answer = gets.chomp.upcase.strip
    until answer.match?(/^Y$|^N$/)
      print "\nplease enter Y or N: "
      answer = gets.chomp.upcase.strip
    end
    answer == 'Y' ? Game.load_game : @hangman.play
  end

  def to_yaml
    YAML.dump ({
        :dictionary =>  @dictionary,
        :display    => @display,
        :self       => self
    })
  end

  def self.from_yaml(string)
    data = YAML.safe_load(string)
    Game.new(data[:dictionary], data[:display], data[:self])
  end

  def save_game
    serialized = to_yaml
    print "\nName your game something, e.g. 'game': "
    fname = gets.chomp.downcase.strip + '.yaml'
    saved_game = File.open(fname, 'w')
    puts "\n* Your game has been saved * ".colorize(:magenta)
    saved_game.puts serialized
    saved_game.close
  end

  def self.load_game
    $loaded_game = true
    print "\nEnter the name of the game you'd like to load: "
    fname = gets.chomp.downcase.strip + '.yaml'
    loaded_game = File.open(fname, 'r')
    puts "\n* Your game has loaded! *".colorize(:magenta)
    from_yaml(loaded_game)
  end

  def show_welcome_message
    puts <<-HEREDOC

        Welcome to Hangman!

        A secret word has been generated at random.
        Try to guess the letters of the secret word.
        You may guess the entire word at any time.
        If a letter guess is correct, 
        game will show where that letter occurs in the word.

        You will only have a few tries before the man is hanged!
        
        If at any time you'd like to save your progress,
        type SAVE instead of guessing a letter.
        
        Good luck!

    HEREDOC
  end

  def self.prompt_to_play_again
    print "\nWould you like to play again? enter Y or N: ".colorize(:magenta)
    answer = gets.chomp.upcase.strip
    until answer.match?(/^Y$|^N$/)
      print "\nplease enter Y or N: "
      answer = gets.chomp.upcase.strip
    end
    $loaded_game = false #starting new game, option to load after
    answer == 'Y' ? new(@dictionary, @display, @hangman) : exit
  end
end

# generates a random word from a .txt file
class Dictionary
  attr_accessor :winning_word

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

  def show
    puts
    print 'word --> '
    progress.each { |place| print "#{place} ".colorize(:green) }
    puts
  end
end

# can make a guess
# also has option to save the game
class Hangman < Game
  def initialize(dictionary, display)
    @dictionary = dictionary
    @display = display
    @letter_guess = ''
    @correct_guess = false
    @incorrect_guesses = []
    @num_of_guesses = 0
    @allowed_guesses = @dictionary.winning_word.length * 2
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
    @display.show
    print "\nplease enter a letter or guess the entire word: "
    @letter_guess = gets.chomp.downcase.strip
    save_game if @letter_guess == 'save'
    until @letter_guess.match?(/[a-z*]/)
      print "\nenter a single letter, guess the entire word, or 'save': "
      @letter_guess = gets.chomp.downcase.strip
      save_game if @letter_guess == 'save'
    end
    print '=' * 50 unless @letter_guess == 'save'
  end

  def check_win_increment_guesses
    puts
    @num_of_guesses += 1 unless @letter_guess == 'save'
    unless @dictionary.winning_word.include?(@letter_guess) || @letter_guess == 'save'
      display_incorrect
      puts "remaining guesses: #{@allowed_guesses - @num_of_guesses}"
    end
    check_for_win
  end

  def display_incorrect
    unless @incorrect_guesses.include?(@letter_guess)
      @incorrect_guesses << @letter_guess
    end
    puts "#{@letter_guess} = incorrect".colorize(:red)
    puts "not included: #{@incorrect_guesses}"
  end

  def check_for_win
    if @display.progress == @dictionary.winning_word.split('') || @letter_guess == @dictionary.winning_word
      @correct_guess = true
      puts "\n* You win! *\n".colorize(:magenta)
      puts "Winning word: #{@dictionary.winning_word.colorize(:green)}"
      Game.prompt_to_play_again
    elsif @num_of_guesses == @allowed_guesses
      puts "\n* Sorry, you lose. *\n".colorize(:magenta)
      puts "Winning word: #{@dictionary.winning_word.colorize(:green)}"
      Game.prompt_to_play_again
    end
  end
end

Game.new(@dictionary, @display, @hangman)
