class Compressible
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
      def write_javascript(*args, &block)
        paths = args.dup.flatten
        options = paths.extract_options!
        options[:to] = asset_name(options[:to])
        options[:munge] = options.has_key?(:munge) ? options[:munge] : true
        paths << options
        process(:javascript, *paths, &block)
      end
      
      def write_stylesheet(*args, &block)
        paths = args.dup.flatten
        options = paths.extract_options!
        options[:to] = asset_name(options[:to])
        paths << options
        process(:stylesheet, *paths, &block)
      end
      
      def process(type, *paths, &block)
        require 'yui/compressor' unless defined?(::YUI)
        options = paths.extract_options!
        to      = options[:to]
        
        raise 'must define result file name via :to => name' unless to
        
        compressor = compressor_for(type, options)

        paths = localize(type, *paths)

        start_size = size(type, *paths.map(&:first))
        
        compressed = paths.collect do |path, print_path|
          puts "Compressing '#{print_path}'... (#{size(type, path)})" if Compressible::SAY == true
          result = compressor.compress(read(type, path))
          next if result.blank?
          result = yield(print_path, result).to_s if block_given?
          result
        end.join("")
        
        write(type, to, compressed)
        
        destroy
        
        end_size = size(type, to)
        
        puts "Compressed to '#{to.to_s}' (#{end_size} from #{start_size})" if Compressible::SAY == true
        
        compressed
      end
      
      def compressor_for(type, options = {})
        {
          :javascript => YUI::JavaScriptCompressor,
          :stylesheet => YUI::CssCompressor
        }[type].new(options.reject {|k,v| k.to_s !~ /(munge|charset|linebreak|optimize|preserve_semicolons)/})
      end
      
      def write(type, to, result)
        File.open(path_for(type, to), "w+") {|f| f.puts result}
      end
    end
  end 
end