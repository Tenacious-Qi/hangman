# frozen_string_literal: true

# controls logic of hangman. player makes guesses. feedback provided.
# also has option to save the game
class Hangman < Game
  def initialize(dictionary, display)
    @dictionary = dictionary
    @display = display
    @dictionary = Dictionary.new
    @display = Display.new(@dictionary)
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
    save_or_exit
    until @guess.match?(/[a-z*]|\b[3-4]\b/)
      print "\nenter a single letter, guess the entire word. [3] to save. [4] to exit: "
      @guess = gets.chomp.downcase.strip
      save_or_exit
    end
    print '=' * 50
  end

  def save_or_exit
    save_game if @guess == '3'
    exit if @guess == '4'
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
    unless @dictionary.winning_word.include?(@guess) || @guess == '3'
      show_incorrect
      puts "\nremaining guesses: #{@allowed_guesses - @num_of_guesses}"
    end
    check_for_win
  end

  def show_incorrect
    @incorrect_guesses << @guess unless @incorrect_guesses.include?(@guess)
    print 'incorrect: '
    @incorrect_guesses.each { |guess| print "#{guess} ".colorize(:red) }
  end

  def check_for_win
    split_word = @dictionary.winning_word.split('')
    if @display.progress == split_word || @guess == @dictionary.winning_word
      @correct_guess = true
      @display.show_win_message
    elsif @num_of_guesses == @allowed_guesses
      @display.show_lose_message
    end
  end
end
