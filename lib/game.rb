# frozen_string_literal: true

# when initialized, generate random word
# controls saving and loading
# on load, allow option to open one of saved games
class Game
  attr_accessor :dictionary, :display

  @@loaded_game = false

  def initialize(dictionary, display, hangman)
    @dictionary = dictionary
    @display = display
    @hangman = hangman
    unless @@loaded_game
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
    puts "\nWould you like to start a new game or load a saved one?"
    print "\nEnter 'N' to play a new game or 'L' to load a saved game: "
    answer = gets.chomp.upcase.strip
    until answer.match?(/^N$|^L$/)
      print "\nplease enter N or L: "
      answer = gets.chomp.upcase.strip
    end
    answer == 'N' ? @hangman.play : Game.load_game
  end

  def to_yaml
    YAML.dump({  dictionary: @dictionary,
                 display: @display,
                 self: self })
  end

  def self.from_yaml(string)
    data = YAML.load(string)
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
    @@loaded_game = true
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
    @@loaded_game = false # starting new game, option to load after
    answer == 'Y' ? new(@dictionary, @display, @hangman) : exit
  end
end
