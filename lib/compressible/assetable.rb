module Compressible
  module Assetable
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
    
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
  
      def javascript(*args)
        paths = args.dup
        options = paths.extract_options!
        to = asset_name(options[:to])
        add_to_config(:js, to, paths)
        write_javascript(*args) unless config[:read_only] == true
      end
      alias_method :add_javascript, :javascript
      alias_method :js, :javascript

      def stylesheet(*args)
        paths = args.dup
        options = paths.extract_options!
        to = asset_name(options[:to])
        add_to_config(:css, to, paths)
        write_stylesheet(*args) unless config[:read_only] == true
      end
      alias_method :add_stylesheet, :stylesheet
      alias_method :css, :stylesheet
      
    end
  end
end