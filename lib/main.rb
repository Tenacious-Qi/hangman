# frozen_string_literal: true

require 'colorize'
require 'yaml'
require_relative 'game.rb'
require_relative 'dictionary.rb'
require_relative 'display.rb'
require_relative 'hangman.rb'

Game.new(@dictionary, @display, @hangman)
