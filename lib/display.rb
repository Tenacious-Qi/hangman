# frozen_string_literal: true

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
