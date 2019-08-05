require 'rubygems'
require 'bundler'

Bundler.require

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ical-stripper'

run ICalStripper::Web
