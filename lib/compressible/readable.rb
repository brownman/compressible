module Compressible
  module Readable
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
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

      def stylesheets_for(*keys)
        assets_for(:stylesheet, *keys)
      end

      def javascripts_for(*keys)
        assets_for(:javascript, *keys)
      end

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

      def asset_name(path)
        result = path.to_s.split(".")
        if result.last =~ /(js|css)/
          result = result[0..-2].join(".")
        else
          result = result.join(".")
        end
        result
      end

      # ultimately should return global path
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
      
      def size(type, *paths)
        result = paths.collect { |path| File.size(path_for(type, path)) }.inject(0) { |sum, x| sum + x }
        by = "kb"
        unless result <= 0
          result = case by
          when "kb"
            result / 1_000
          when "mb"
            result / 1_000_000
          end
        end
        return "#{result.to_s}#{by}"
      end
      
      def read(type, from)
        IO.read(path_for(type, from))
      end
    end
    
  end
end