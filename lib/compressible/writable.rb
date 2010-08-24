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
        
        paths = localize(to, type, *paths)
        
        start_size = size(type, *paths.map(&:first))
        
        compressed = paths.collect do |path, print_path|
          puts "Compressing '#{print_path}'... (#{size(type, path)})"
          result = compressor.compress(read(type, path))
          next if result.blank?
          result = yield(path, result).to_s if block_given?
          result
        end.join("")
        
        write(type, to, compressed)
        
        destroy(*paths)
        
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
      
      def localize(to, type, *paths)
        FileUtils.mkdir_p(to) unless File.exists?(to)
        local_paths = paths.map do |path|
          if remote?(path)
            local = File.join(to, File.basename(path))
            File.open(local, "w+") do |file|
              begin
                file.puts read(type, path)
              rescue Exception => e
                paths.delete(path)
                puts "#{e.message}: #{path}"
              end
            end
            [local, path]
          else
            [path, path]
          end
        end
      end
      
      def remote_path(domain, path, asset)
        # full
        if asset =~ /^http(?:s)?:\/\//
          asset
        # absolute
        elsif asset =~ /^\//
          asset = "#{domain}#{asset}"
        # relative
        else
          asset = "#{domain}#{path}/#{asset}"
        end
      end
      
      # returns css and javascripts {:js => [], :css => []}
      # requires nokogiri
      def scrape(page)
        require 'nokogiri'
        url = URI.parse(page)
        domain =   "#{url.scheme}://#{url.host}"
        domain <<  ":#{url.port.to_s}"
        path = url.path.squeeze("/")
        html = Nokogiri::HTML(open(page).read)
        scripts = []
        
        html.css("script").each do |script|
          next if script["src"].blank?
          scripts << remote_path(domain, path, script["src"])
        end
        
        csses = []
        
        html.css("link[rel=stylesheet]").each do |css|
          next if css["href"].blank?
          csses << remote_path(domain, path, css["href"])
        end
        
        {:js => scripts, :css => csses}
      end
      
      def destroy(*paths)
        paths.each do |path, print_path|
          if path != print_path
            File.delete(path) if File.exists?(path)
          end
        end
      end
    end
  end 
end