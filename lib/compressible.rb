require 'rubygems'
require 'yaml'
require 'open-uri'
require 'active_support/core_ext'

this = File.dirname(__FILE__)
require File.join(this, "ext.rb")

class Compressible
  
  KEYS = {
    :css => :stylesheet,
    :stylesheet => :css,
    :js => :javascript,
    :javascript => :js
  }
  
  SAY = true unless defined?(Compressible::SAY)
  
  TMP = "." unless defined?(Compressible::TMP)
  
end

Dir["#{this}/compressible/*"].each { |c| require c }

Compressible.send(:include, Compressible::Configurable)
Compressible.send(:include, Compressible::Assetable)
Compressible.send(:include, Compressible::Readable)
Compressible.send(:include, Compressible::Scrapable)
Compressible.send(:include, Compressible::Writable)

def Compressible(*args, &block)
  Compressible.define!(*args, &block)
end
