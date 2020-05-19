# frozen_string_literal: true

require 'bundler/inline'

gemfile true do
 source 'http://rubygems.org'
 gem 'colorize'
end

require 'yaml'
require 'colorize'
require_relative 'game.rb'
require_relative 'dictionary.rb'
require_relative 'display.rb'
require_relative 'hangman.rb'

Game.new(@dictionary, @display, @hangman)
