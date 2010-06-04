require 'rubygems'
require 'yaml'
begin
  gem "activesupport", "= 2.3.5"
  require 'active_support'
rescue Gem::LoadError => e
  puts e.inspect
end
require 'yui/compressor'
this = File.dirname(__FILE__)
require File.join(this, "ext.rb")

class Compressible
  
  KEYS = {
    :css => :stylesheet,
    :stylesheet => :css,
    :js => :javascript,
    :javascript => :js
  }
  
  class << self
    
    attr_reader :config
    
    def configure(value = nil)
      raise "invalid config" unless (value.is_a?(String) || value.is_a?(Hash))
      @config = value.is_a?(String) ? YAML.load_file(value) : value
      @config.recursively_symbolize_keys!
      
      # normalize everything to an array
      [:js, :css].each do |type|
        @config[type] = [@config[type]] unless @config[type].is_a?(Array)
      end
      
      # remove rails dependency at some point
      @config[:stylesheet_path] ||= "#{Rails.root}/public/stylesheets"
      @config[:javascript_path] ||= "#{Rails.root}/public/javascripts"
      
      @config
    end
    
    def reset
      @config = nil
    end
    
    def uncached_stylesheet_paths(*keys)
      uncached_paths_for(:css, *keys)
    end
    
    def uncached_javascript_paths(*keys)
      uncached_paths_for(:js, *keys)
    end
    
    def uncached_paths_for(type, *keys)
      returning [] do |result|
        config[type].each do |item|
          keys.each do |key|
            result.concat(item[:paths]) if item[:to] == key.to_s
          end
        end
      end
    end
    
    # called if you gave it a config
    def compress(value = nil)
      configure(value) if value
      raise "set config to yaml file or run 'Compressible.js' or 'Compressible.css' manually" unless @config
      
      [:js, :css].each do |k|
        config[k].each do |item|
          compress_from_hash(k, item)
        end
      end
    end
    
    def compress_from_hash(k, v)
      args = v.dup.delete(:paths) + [v]
      self.send(k, *args)
    end
    
    def javascripts(hash)
      hash.each do |to, paths|
        paths << {:to => to}
        javascript(*paths)
      end
    end
    alias_method :add_javascripts, :javascripts
    
    def stylesheets(hash)
      hash.each do |to, paths|
        paths << {:to => to}
        stylesheet(*paths)
      end
    end
    alias_method :add_stylesheets, :stylesheets
    
    def javascript(*paths)
      options = paths.extract_options!
      to = options[:to]
      munge = options.has_key?(:munge) ? options[:munge] : true
      
      compressor = YUI::JavaScriptCompressor.new(:munge => munge)
      
      result = paths.collect do |path|
        puts "Compressing #{path}..."
        compressor.compress(read(:javascript, path))
      end.join("\n\n")
      
      write(:javascript, to, result) if to
      
      result
    end
    alias_method :add_javascript, :javascript
    alias_method :js, :javascript
    
    def stylesheet(*paths)
      options = paths.extract_options!
      to = options[:to]
      
      compressor = YUI::CssCompressor.new
      
      result = paths.collect do |path|
        puts "Compressing #{path}..."
        compressor.compress(read(:stylesheet, path))
      end.join("\n\n")
      
      write(:stylesheet, to, result) if to
      
      result
    end
    alias_method :add_stylesheet, :stylesheet
    alias_method :css, :stylesheet
    
    def assets_for(type, *keys)
      options = keys.extract_options!
      environment = defined?(Rails) ? Rails.env.to_s : (options[:current] || "production")
      environment = environment.to_s
      cache_environments = options[:environments] || "production"
      cache_environments = [cache_environments] unless cache_environments.is_a?(Array)
      cache_environments = cache_environments.collect(&:to_s)
      
      assets = cache_environments.include?(environment) ? keys : send("uncached_#{type.to_s}_paths", *keys)
      assets
    end
    
    def read(type, from)
      IO.read(path_for(type, from))
    end
    
    def write(type, to, result)
      File.open(path_for(type, to), "w") {|f| f.puts result}
    end
    
    def path_for(type, file)
      key = "#{type.to_s}_path".to_sym
      
      if config && config[key]
        path = File.join(config[key], file.to_s)
      elsif defined?(Rails)
        path = File.join(Rails.root.to_s, "public/#{type.to_s.pluralize}", file.to_s)
      else
        path = file.to_s
      end
      
      path << ".#{KEYS[type].to_s}" unless path.split(".").last == KEYS[type].to_s
      
      path
    end
    
  end
  
end

Dir["#{this}/compressible/*"].each { |c| require c }
