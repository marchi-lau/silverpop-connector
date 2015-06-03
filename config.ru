require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra/base'

require_relative 'base'
require 'open-uri'
require_relative 'libs/silverpop'
require_relative 'libs/airport'
require_relative 'libs/cabin'
require_relative 'libs/destination_guide'
#require_relative 'libs/deep_link'
require_relative 'mailers/cart_abandonment'

run SilverpopConnector