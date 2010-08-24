module Compressible
  module Assetable
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
    
      def javascripts(hash, &block)
        hash.each do |to, paths|
          paths << {:to => to}
          javascript(*paths, &block)
        end
      end
      alias_method :add_javascripts, :javascripts

      def stylesheets(hash, &block)
        hash.each do |to, paths|
          paths << {:to => to}
          stylesheet(*paths, &block)
        end
      end
      alias_method :add_stylesheets, :stylesheets
  
      def javascript(*args, &block)
        paths = args.dup.flatten
        options = paths.extract_options!
        to = asset_name(options[:to])
        add_to_config(:js, to, paths)
        write_javascript(*args, &block) unless config[:read_only] == true
        to
      end
      alias_method :add_javascript, :javascript
      alias_method :js, :javascript

      def stylesheet(*args, &block)
        paths = args.dup.flatten
        options = paths.extract_options!
        to = asset_name(options[:to])
        add_to_config(:css, to, paths)
        write_stylesheet(*args, &block) unless config[:read_only] == true
        to
      end
      alias_method :add_stylesheet, :stylesheet
      alias_method :css, :stylesheet
      
    end
  end
end