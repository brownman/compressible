require 'rubygems'
require 'yaml'
gem "activesupport", "= 2.3.5"
require 'active_support'
require 'yui/compressor'
require File.join(File.dirname(__FILE__), "ext.rb")

class Compressible
  
  class << self
    
    attr_reader :config
    
    def configure(value = nil)
      raise "invalid config" unless (value.is_a?(String) || value.is_a?(Hash))
      @config = value.is_a?(String) ? YAML.load_file(value) : value
      @config.recursively_symbolize_keys!
    end
    
    def reset
      @config = nil
    end
    
    # called if you gave it a config
    def compress(value = nil)
      configure(value) if value
      raise "set config to yaml file or run 'Compressible.js' or 'Compressible.css' manually" unless @config
      
      config.each do |k, v|
        args = v.delete(:paths) + [v]
        self.send(k, *args)
      end
    end
    
    def js(*paths)
      options = paths.extract_options!
      to = options[:to]
      munge = options.has_key?(:munge) ? options[:munge] : true
      
      compressor = YUI::JavaScriptCompressor.new(:munge => munge)
      
      result = paths.collect do |path|
        puts "Compressing #{path}..."
        compressor.compress(IO.read(path))
      end.join("\n\n")
      
      File.open(to, "w") {|f| f.puts result} if to
      
      result
    end
    
    def css(*paths)
      options = paths.extract_options!
      to = options[:to]
      
      compressor = YUI::CssCompressor.new
      
      result = paths.collect do |path|
        puts "Compressing #{path}..."
        compressor.compress(IO.read(path))
      end.join("\n\n")
      
      File.open(to, "w") {|f| f.puts result} if to
      
      result
    end
    
  end
  
end