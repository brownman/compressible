module Compressible
  module Configurable
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      attr_reader :config

      def configure(value = nil)
        raise "invalid config" unless (value.is_a?(String) || value.is_a?(Hash))
        @config = value.is_a?(String) ? YAML.load_file(value) : value
        @config.recursively_symbolize_keys!

        @config = defaults.merge(@config)

        # normalize everything to an array
        [:js, :css].each do |type|
          @config[type] = [@config[type]] unless @config[type].is_a?(Array)
        end

        @config
      end

      def defaults
        {
          :js => [],
          :css => [],
          :stylesheet_path => defined?(Rails) ? "#{Rails.root}/public/stylesheets" : nil,
          :javascript_path => defined?(Rails) ? "#{Rails.root}/public/javascripts" : nil,
          :read_only => false
        }
      end

      def config
        @config ||= defaults
      end

      def add_to_config(type, key, value)
        item = find_or_create(type, key)
        item[:paths] = value.collect {|i| asset_name(i)}
        item
      end

      def find_or_create(type, key)
        result = config[type].detect {|i| i[:to].to_s == key.to_s}
        unless result
          result = {:to => key.to_s}
          config[type] << result
        end
        result
      end

      def reset
        @config = defaults
      end
    end
    
  end
end