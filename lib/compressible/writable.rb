module Compressible
  module Writable
    
    def self.included(base)
      base.extend ClassMethods
    end
  
    module ClassMethods
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
      
      # figure out how to do alias_method_chain or something
      # otherwise the modules are tightly coupled
      def write_javascript(*args)
        paths = args.dup
        options = paths.extract_options!
        to = asset_name(options[:to])
        require 'yui/compressor' unless defined?(YUI)

        munge = options.has_key?(:munge) ? options[:munge] : true

        compressor = YUI::JavaScriptCompressor.new(:munge => munge)

        result = paths.collect do |path|
          puts "Compressing #{path}..."
          compressor.compress(read(:javascript, path))
        end.join("\n\n")

        write(:javascript, to, result) if to

        result
      end
      
      def write_stylesheet(*args)
        paths = args.dup
        options = paths.extract_options!
        to = asset_name(options[:to])

        add_to_config(:css, to, paths)

        return if options[:read_only] == true
    
        require 'yui/compressor' unless defined?(YUI)

        compressor = YUI::CssCompressor.new

        result = paths.collect do |path|
          puts "Compressing #{path}..."
          compressor.compress(read(:stylesheet, path))
        end.join("\n\n")

        write(:stylesheet, to, result) if to

        result
      end
      
      def write(type, to, result)
        File.open(path_for(type, to), "w") {|f| f.puts result}
      end
    end
  end 
end