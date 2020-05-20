# frozen_string_literal: true

require 'yaml'
require 'colorize'
require_relative 'lib/game.rb'
require_relative 'lib/dictionary.rb'
require_relative 'lib/display.rb'
require_relative 'lib/hangman.rb'

Game.new(@hangman)
