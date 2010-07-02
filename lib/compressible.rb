require 'rubygems'
require 'yaml'
require 'active_support'

this = File.dirname(__FILE__)
require File.join(this, "ext.rb")

module Compressible
  
  KEYS = {
    :css => :stylesheet,
    :stylesheet => :css,
    :js => :javascript,
    :javascript => :js
  }
  
end

Dir["#{this}/compressible/*"].each { |c| require c }

Compressible.send(:include, Compressible::Configurable)
Compressible.send(:include, Compressible::Assetable)
Compressible.send(:include, Compressible::Readable)
Compressible.send(:include, Compressible::Writable)

def Compressible(*args, &block)
  Compressible.define!(*args, &block)
end
