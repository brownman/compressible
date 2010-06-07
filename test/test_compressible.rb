require File.join(File.dirname(__FILE__), "test_helper")

class CompressibleTest < Test::Unit::TestCase
  
  context "Compressible" do
    
    context "configuration" do
            
      should "load configuration file and result should be a Module" do
        assert_kind_of Module, Compressible.configure("test/config.yml")
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
      
      should "compress stylesheets without file extension" do
        assert Compressible.css("test/test-a", "test/test-b", :to => "test/result")
      end
      
    end
    
    context "compress all" do
      
      setup { Compressible.configure("test/config.yml") }
      
      should "run dynamic compression methods from config" do
        assert Compressible.compress
      end
      
      context "view tags" do

        should "find uncached version of a stylesheet from a key" do
          assert_equal ["test/test-a", "test/test-b"], Compressible.uncached_stylesheet_paths("test/result")
        end
        
        should "use cached tags if we're in a 'production' environment (default)" do
          assets = Compressible.assets_for(:stylesheet, 'test/result', :environments => "production")
          assert_equal ["test/result"], assets
        end
        
        should "use uncached tags if we're not in a 'production' environment (development)" do
          assets = Compressible.assets_for(:stylesheet, 'test/result', :environments => "production", :current => "development")
          assert_equal ["test/test-a", "test/test-b"], assets
        end
        
      end
      
      teardown { Compressible.reset }
      
    end
    
    context "without yaml config" do
      
      setup { Compressible.reset }
      
      should "add javascript to the config hash" do
        assert_equal [], Compressible.config[:js]
        Compressible.js("test/test-a", "test/test-b", :to => "test/result")
        assert_equal ["test/test-a", "test/test-b"], Compressible.config[:js][0][:paths]
      end
      
      should "be able to add config dynamically" do
        assert_equal Compressible.defaults, Compressible.config
        Compressible.configure(:stylesheet_path => "public/stylesheets", :read_only => true)
        assert_equal "public/stylesheets", Compressible.config[:stylesheet_path]
        Compressible.stylesheets("test/result" => ["test/test-a", "test/test-b"])
        assets = Compressible.assets_for(:stylesheet, 'test/result', :environments => "production", :current => "development")
        assert_equal ["test/test-a", "test/test-b"], assets
        result = {:js=>[], :javascript_path=>nil, :stylesheet_path=>"public/stylesheets", :read_only=>true, :css=>[{:paths=>["test/test-a", "test/test-b"], :to=>"test/result"}]}
        assert_equal result, Compressible.config
      end
      
      teardown { Compressible.reset }
      
    end
    
    
  end
  
end