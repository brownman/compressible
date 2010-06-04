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
        options[:to] = asset_name(options[:to])
        options[:munge] = options.has_key?(:munge) ? options[:munge] : true
        paths << options
        process(:javascript, *paths)
      end
      
      def write_stylesheet(*args)
        paths = args.dup
        options = paths.extract_options!
        options[:to] = asset_name(options[:to])
        paths << options
        process(:stylesheet, *paths)
      end
      
      def process(type, *paths)
        require 'yui/compressor' unless defined?(::YUI)
        options = paths.extract_options!
        to      = options[:to]
        
        raise 'must define result file name via :to => name' unless to
        
        compressor = compressor_for(type, options)
        
        start_size = size(type, *paths)
        
        compressed = paths.collect do |path|
          puts "Compressing '#{path}'... (#{size(type, path)})"
          compressor.compress(read(type, path))
        end.join("\n\n")
        
        write(type, to, compressed)
        
        end_size = size(type, to)
        
        puts "Compressed to '#{to.to_s}' (#{end_size} from #{start_size})"
        
        compressed
      end
      
      def compressor_for(type, options = {})
        {
          :javascript => YUI::JavaScriptCompressor,
          :stylesheet => YUI::CssCompressor
        }[type].new(options.reject {|k,v| k.to_s !~ /(munge|charset|linebreak|optimize|preserve_semicolons)/})
      end
      
      def write(type, to, result)
        File.open(path_for(type, to), "w") {|f| f.puts result}
      end
    end
  end 
end