begin
  require 'rubygems'
  gem 'libxml', '>= 0.8.3'
  require 'bitbckt/core_ext/hash/conversions'
  
  Hash.send :include, Bitbckt::CoreExtensions::Hash::Conversions
rescue LoadError
  puts 'libxml-ruby version 0.8.3 required.'
end