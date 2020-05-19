# frozen_string_literal: true

require 'yaml'
require 'colorize'
require_relative 'game.rb'
require_relative 'dictionary.rb'
require_relative 'display.rb'
require_relative 'hangman.rb'

Game.new(@dictionary, @display, @hangman)
