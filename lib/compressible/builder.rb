module Compressible
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
        Compressible.send(@context, args, :to => [meth])
      else
        super(meth, *args, &block)
      end
    end
  end
end
