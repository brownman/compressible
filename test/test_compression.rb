require File.join(File.dirname(__FILE__), "test_helper")

class CompressibleTest < Test::Unit::TestCase
  
  context "Compressible" do
    
    context "configuration" do
            
      should "load configuration file and result should be a hash" do
        assert_kind_of Hash, Compressible.configure("test/config.yml")
      end
      
      should "raise an RuntimeError if pass junk to config" do
        assert_raise(RuntimeError) { Compressible.configure([]) }
      end
      
      context "with correct configuration" do
        
        setup { Compressible.configure("test/config.yml") }
        
        should "have symbols for keys, not strings (symbolize keys, been a problem in the past)" do
          Compressible.config.each_key do |k|
            assert_kind_of Symbol, k
          end
        end
        
      end
      
      teardown { Compressible.reset }
      
    end
    
    context "javascript compression" do
      
      setup do
        @js = <<-eos
          function (x, t, b, c, d) {
        		//alert(jQuery.easing.default);
        		return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
        	}
        eos
      end
      
      should "compress javascript" do
        assert Compressible.js("test/test-a.js", "test/test-b.js", :to => "test/result.js")
      end
      
    end
    
    context "css compression" do
      
      setup do
        @css = <<-eos
          a.pp_contract {
      			cursor: pointer;
      			display: none;
      			height: 20px;	
      			position: absolute;
      			right: 30px;
      			text-indent: -10000px;
      			top: 10px;
      			width: 20px;
      			z-index: 20000;
      		}
        eos
      end
      
      should "compress stylesheets" do
        assert Compressible.css("test/test-a.css", "test/test-b.css", :to => "test/result.css")
      end
      
    end
    
    context "compress all" do
      
      setup { Compressible.configure("test/config.yml") }
      
      should "run dynamic compression methods from config" do
        assert Compressible.compress
      end
      
    end
    
  end
  
end