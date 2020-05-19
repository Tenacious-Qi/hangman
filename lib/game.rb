# frozen_string_literal: true

# starts game. controls saving and loading
# on load, allow option to open one of saved games
class Game
  attr_accessor :dictionary, :display

  @@loaded_game = false
  @@new_game_requested = false

  def initialize(dictionary, display, hangman)
    @dictionary = dictionary
    @display = display
    @hangman = hangman
    @selected_option = ''
    unless @@loaded_game
      @hangman = Hangman.new(@dictionary, @display)
      prompt_to_load_game unless @@new_game_requested
    end
    @hangman.play
  end

  def prompt_to_load_game
    Display.show_options
    @selected_option = gets.chomp.upcase.strip
    until @selected_option.match?(/\b[1-4]\b/)
      print "\nplease enter 1, 2, 3, or 4: "
      @selected_option = gets.chomp.upcase.strip
    end
    check_selected_option
  end

  def check_selected_option
    Game.start_new_game if @selected_option == '1'
    Game.load_game if @selected_option == '2'
    @hangman.save_game if @selected_option == '3'
    exit if @selected_option == '4'
  end

  def self.start_new_game
    @@new_game_requested = true
    puts "\n\t* New game started! *\n".colorize(:magenta)
    Display.show_welcome_message
    @hangman = Hangman.new(@dictionary, @display)
    Game.new(@dictionary, @display, @hangman)
  end

  def self.load_game
    @@loaded_game = true
    print "\nEnter the name of the game you'd like to load: "
    fname = gets.chomp.downcase.strip + '.yaml'
    loaded_game = File.open(fname, 'r')
    puts "\n* Your game has loaded! *".colorize(:magenta)
    from_yaml(loaded_game)
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

  def to_yaml
    YAML.dump({  dictionary: @dictionary,
                 display: @display,
                 self: self })
  end

  def self.from_yaml(string)
    data = YAML.load(string)
    Game.new(data[:dictionary], data[:display], data[:self])
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
