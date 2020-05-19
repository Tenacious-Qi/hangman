# frozen_string_literal: true

# can make a guess
# also has option to save the game
class Hangman < Game
  def initialize(dictionary, display)
    @dictionary = dictionary
    @display = display
    @guess = ''
    @correct_guess = false
    @incorrect_guesses = []
    @num_of_guesses = 0
    @allowed_guesses = @dictionary.winning_word.length * 2
  end

  def play
    until @correct_guess || @num_of_guesses == @allowed_guesses
      prompt_for_letter
      @display.progress.each_with_index do |_space, index|
        if @dictionary.winning_word[index] == @guess
          @display.progress[index] = @guess
        end
      end
      check_win_increment_guesses
    end
  end

  def prompt_for_letter
    request_letter
    save_game if @guess == 'save'
    until @guess.match?(/[a-z*]/)
      print "\nenter a single letter, guess the entire word, or 'save': "
      @guess = gets.chomp.downcase.strip
      save_game if @guess == 'save'
    end
    print '=' * 50
  end

  def request_letter
    @display.show
    print "\nplease enter a letter or guess the entire word: "
    @guess = gets.chomp.downcase.strip
    puts "\nalready there!".colorize(:red) if @display.progress.include?(@guess)
  end

  def check_win_increment_guesses
    puts
    @num_of_guesses += 1 unless @guess == 'save'
    unless @dictionary.winning_word.include?(@guess) || @guess == 'save'
      display_incorrect
      puts "\nremaining guesses: #{@allowed_guesses - @num_of_guesses}"
    end
    check_for_win
  end

  def display_incorrect
    @incorrect_guesses << @guess unless @incorrect_guesses.include?(@guess)
    print 'incorrect: '
    @incorrect_guesses.each { |guess| print "#{guess} ".colorize(:red) }
  end

  def check_for_win
    split_word = @dictionary.winning_word.split('')
    if @display.progress == split_word || @guess == @dictionary.winning_word
      @correct_guess = true
      show_win_message
    elsif @num_of_guesses == @allowed_guesses
      show_lose_message
    end
  end

  def show_win_message
    puts "\n* You win! *\n".colorize(:magenta)
    puts "Winning word: #{@dictionary.winning_word.colorize(:green)}"
    Game.prompt_to_play_again
  end

  def show_lose_message
    puts "\n* Sorry, you lose. *\n".colorize(:magenta)
    puts "Winning word: #{@dictionary.winning_word.colorize(:green)}"
    Game.prompt_to_play_again
  end
end
