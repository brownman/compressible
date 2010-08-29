class Compressible
  class Builder
    class << self
      def define!(*args, &block)
        new(*args, &block)
      end
    end
    
    def initialize(*args, &block)
      instance_eval(&block) if block_given?
    end
    
    def read_only(value = true)
      Compressible.configure(:read_only => value)
    end
    
    def stylesheet_path(value)
      Compressible.configure(:stylesheet_path => value)
    end
    
    def javascript_path(value)
      Compressible.configure(:javascript_path => value)
    end
    
    # used to customize the output
    def format(context = nil, &block)
      if block_given?
        context ||= @context
        @format ||= {}
        @format[context] = block
      end
    end
    
    def stylesheets(&block)
      @context = "stylesheet"
      instance_eval(&block) if block_given?
      @context = nil
    end
    
    def javascripts(&block)
      @context = "javascript"
      instance_eval(&block) if block_given?
      @context = nil
    end
    
    def method_missing(meth, *args, &block)
      if @context
        format(@context, &block)
        Compressible.send(@context, args, :to => [meth]) do |name, output|
          modify(name, output)
        end
      else
        super(meth, *args, &block)
      end
    end
    
    protected
    def modify(name, output)
      if @format
        return @format[@context].call(name, output) if @format[@context]
      end
      output
    end
  end
end
