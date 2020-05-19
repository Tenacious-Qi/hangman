# frozen_string_literal: true

# starts game. controls saving and loading
# on load, allow option to open one of saved games
class Game
  attr_accessor :dictionary, :display

  @@loaded_game = false

  def initialize(dictionary, display, hangman)
    @dictionary = dictionary
    @display = display
    @hangman = hangman
    unless @@loaded_game
      Display.show_welcome_message
      @hangman = Hangman.new(@dictionary, @display)
      prompt_to_load_game
    end
    @hangman.play
  end

  def prompt_to_load_game
    puts "\nWould you like to start a new game or load a saved one?"
    print "\nEnter [1] to play a new game or [2] to load a saved game: "
    answer = gets.chomp.upcase.strip
    until answer.match?(/^1$|^2$/)
      print "\nplease enter 1 or 2: "
      answer = gets.chomp.upcase.strip
    end
    answer == '1' ? @hangman.play : Game.load_game
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
