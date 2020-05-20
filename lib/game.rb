# frozen_string_literal: true

# starts game. controls saving and loading
# on load, allow option to open one of saved games
class Game
  @loaded_game = false
  @new_game_requested = false

  class << self
    attr_accessor :loaded_game, :new_game_requested
  end

  def initialize(hangman)
    @hangman = hangman
    @selected_option = ''
    @avail_games = []
    unless self.class.loaded_game
      @hangman = Hangman.new(@dictionary, @display)
      prompt_with_options unless self.class.new_game_requested
    end
    @hangman.play
  end

  def prompt_with_options
    Display.show_options
    @selected_option = gets.chomp.upcase.strip
    until @selected_option.match?(/\b[1-4]\b/)
      print "\nplease enter 1, 2, 3, or 4: "
      @selected_option = gets.chomp.strip
    end
    check_selected_option
  end

  def check_selected_option
    Game.start_new_game          if @selected_option == '1'
    Game.load_game               if @selected_option == '2'
    @hangman.save_game           if @selected_option == '3'
    Display.show_goodbye_message if @selected_option == '4'
  end

  def self.start_new_game
    self.new_game_requested = true
    puts "\n\t* New game started! *\n".colorize(:magenta)
    Display.show_welcome_message
    @hangman = Hangman.new(@dictionary, @display)
    Game.new(@hangman)
  end

  def save_game
    serialized = to_yaml
    print "\nName your game something, e.g. 'game': "
    fname = gets.chomp.downcase.strip + '.yaml'
    Dir.mkdir('saved_games') unless File.exist?('saved_games')
    saved_game = File.open("saved_games/#{fname}", 'w')
    puts "\n* Your game has been saved * ".colorize(:magenta)
    saved_game.puts serialized
    saved_game.close
  end

  def self.load_game
    self.loaded_game = true
    puts "\nSaved Games:".colorize(:magenta)
    yaml_files = File.join('**', '*.yaml')
    @avail_games = Dir.glob(yaml_files, base: 'saved_games')
    if @avail_games.empty?
      puts ' * No saved games found! *'.colorize(:magenta)
      prompt_to_play_again
    else
      list_and_load_game
    end
  end

  def self.list_and_load_game
    show_available_games
    fname = gets.chomp.downcase.strip + '.yaml'
    unless @avail_games.include?(fname)
      puts "\n* that game isn't here! *".colorize(:magenta)
      prompt_to_play_again
    end
    selected_game = File.open("saved_games/#{fname}", 'r')
    puts "\n* Your game has loaded! *\n".colorize(:magenta)
    from_yaml(selected_game)
  end

  def self.show_available_games
    @avail_games.map { |f| puts "\t* #{f.gsub(/\.yaml/, '')}" }
    print "\nEnter one of the above games: "
  end

  def to_yaml
    YAML.dump(self: self)
  end

  def self.from_yaml(string)
    data = YAML.load(string)
    Game.new(data[:self])
  end

  def self.prompt_to_play_again
    print "\nWould you like to play again? enter Y or N: ".colorize(:magenta)
    answer = gets.chomp.upcase.strip
    until answer.match?(/^Y$|^N$/)
      print "\nplease enter Y or N: "
      answer = gets.chomp.upcase.strip
    end
    self.loaded_game = false # starting new game, option to load after
    answer == 'Y' ? start_new_game : Display.show_goodbye_message
  end
end
