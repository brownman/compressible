require "rubygems"
require "ruby-debug"
gem 'test-unit'
require "test/unit"
require 'active_support'
require 'active_support/test_case'
require 'shoulda'

require File.dirname(__FILE__) + '/../lib/compressible'

Compressible::SAY = true

ActiveSupport::TestCase.class_eval do
  def singular_methods
    Compressible.js("test-a", "test-b", :to => "result", :munge => true)
    Compressible.css("test-a", "test-b", :to => "result")
  end

  def plural_methods

  end

  def builder
    Compressible do
      javascripts do
        send "result", "test-a", "test-b"
      end
      stylesheets do
        send "result", "test-a", "test-b"
      end
    end
  end
end
