# encoding: UTF-8

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'tmx-parser/version'

Gem::Specification.new do |s|
  s.name     = "tmx-parser"
  s.version  = ::TmxParser::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://github.com/camertron"

  s.description = s.summary = "Parser for the Translation Memory eXchange (.tmx) file format."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/*", "Gemfile", "History.txt", "README.md", "Rakefile", "tmx-parser.gemspec"]
  s.add_dependency 'nokogiri', '~> 1.6.0'
end
