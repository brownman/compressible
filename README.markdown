# Compressible

> Ready-to-go Asset Compression for Ruby using the YUICompressor.

Built in pure Ruby.  Integrates perfectly into Rails, Sinatra, Rack, and anything else.  Perfect for Heroku.  Used in several large production Heroku apps already.

## Install

    sudo gem install compressible

## Configuration

You can configure this using a DSL, YAML, or plain ruby methods.

### 1. DSL

    Compressible do
      read_only true
      stylesheet_path "stylesheets"
      javascript_path "javascripts"
      
      stylesheets do
        result "test-a", "test-b"
      end
      
      javascripts do
        send "application-cache", *javascripts do |name, output|
          result = "// #{name}\n"
          result << output
          result << "\n"
          result
        end
      end
    end
    
The block `do |name, output|` is optional, but it allows you to post-process the compressed output.  This is nice b/c it gives you space to add comments and whatnot.  So instead of 10 js libraries being packed together like this (pseudo code):

    (function() {lib1}...)(function() {lib2})...

... with the code from the above block, we can output it like this:
    
    // lib1
    (function() {lib1}...)
    // lib2
    (function() {lib2})...

Here is some sample output from a real page:

    // http://cachedcommons.org/javascripts/jquery/jquery.google-analytics-1.1.3-min.js
    (function(f){var d;f.trackPage=function(c,m){var b=(("https:"==document.location.protocol)...
    // http://cachedcommons.org/javascripts/jquery/jquery.system-0.1.1-min.js                 
    (function(b){b.system={browser:{safari:false,firefox:false,ie:false,opera:false,chrome:fal...
    // http://cachedcommons.org/javascripts/jquery/jquery.form-2.4.3-min.js                   
    (function(c){c.fn.ajaxSubmit=function(D){if(!this.length){d("ajaxSubmit: skipping submit p...
    // http://cachedcommons.org/javascripts/jquery/jquery.hoverIntent-min.js                  
    (function(a){a.fn.hoverIntent=function(k,j){var l={sensitivity:7,interval:100,timeout:0};l...
    // http://cachedcommons.org/javascripts/jquery/jquery.cycle.all-2.8.6-min.js              
    (function(y){var v="2.86";if(y.support==undefined){y.support={opacity:!(y.browser.msie)}}f...
    // http://cachedcommons.org/javascripts/jquery/jquery.validate-1.7-min.js                 
    eval(function(h,b,i,d,g,f){g=function(a){return(a<b?"":g(parseInt(a/b)))+((a=a%b)>35?Strin...
    // http://cachedcommons.org/javascripts/jquery/jquery.rails-min.js                        
    jQuery(function(i){var f=i("meta[name=csrf-token]").attr("content"),h=i("meta[name=csrf-pa...
    // http://cachedcommons.org/javascripts/text/prettify-min.js                              
    window.PR_SHOULD_USE_CONTINUATION=true;window.PR_TAB_WIDTH=8;window.PR_normalizedHtml=wind...
    ...

### 2. YAML

You can also just use YAML.

    js:
      paths:
        - animations
        - effects
        - dragdrop
      to: production_cache
      munge: true
    css:
      -
        paths:
          - reset
          - background
          - footer
          - list
        to: production_cache
      -
        paths:
          - forms
          - headers
          - basic_text
        to: typography

You can then setup everything with `configure`:

    Compressible.configure("config/compressible.yml") # or pass it the yaml hash

## Scraping

Compressible also has a method to parse out the javascripts and stylesheets from an HTML page.  This requires Nokogiri (the rest of the library doesn't use Nokogiri).  You'd use this if you want to say scrape the assets from your Sinatra app, and compress them, rather than having to copy/paste your `javascript_include_tag` declarations elsewhere:

    assets = Compressible.scrape("http://localhost:4567/")
    assets[:js] #=> ["http://localhost:4567/javascripts/application.js", ...]
    assets[:css] #=> ["http://localhost:4567/stylesheets/application.css", ...]
    
You can use this to create a simple pre-deploy Rake task for asset compression:

    task :compress do
      assets = Compressible.scrape("http://localhost:4567")
      
      Compressible do
        read_only false
        javascript_path "javascripts"
        stylesheet_path "stylesheets"
        
        javascripts do
          send "application-cache", *assets[:js] do |name, output|
            result = "// #{name}\n"
            result << output
            result << "\n"
            result
          end
        end
        
        stylesheets do
          send "application-cache", *assets[:css] do |name, output|
            result = "// #{name}\n"
            result << output
            result << "\n"
            result
          end
        end
      end
    end

## Views

Add this to your views:

    compressible_stylesheet_tag "production_cache", "typography"
    compressible_javascript_tag "production_cache"

By default, it will use non-compressed stylesheets when `Rails.env == "development"` or `Sinatra::Application.environment == "development"`, and the compressed stylesheets when  the environment is `"production"`.

To tell it you want to use the cached in a different environment, you can specify it like this:

    compressible_stylesheet_tag "production_cache", :environments => ["production", "staging"], :current => "development"

## API

These are all the methods/options you can use in Compressible:

#### 1. The Compressible block for complete configuration

    Compressible do ...
    
#### 2. Or directly fill the `config` hash

    Compressible.configure(hash or path/to.yml)
    
#### 3. Or fill the `config` hash with only javascript or css (just adds to the `config` hash)
    
    Compressible.js # aliased with `Compressible.javascripts`
    Compressible.css # aliased with `Compressible.stylesheets`

#### 4. Clear the config hash

    Compressible.reset
    
#### 5. Scrape assets from a page

    Compressible.scrape(path) #=> {:js => [], :css => []}
    
#### Read-Only

If the `read_only` config option is `true`, then it won't try to write (aka compress) the assets.  Use this during development mode, so when you startup your Rails/Sinatra app, Compressible doesn't spend time downloading and compressing the assets.  When you deploy, set `read_only = false`, so that it will download and compress the assets.

## Awesome Assets for Heroku

Because Heroku is a Read-Only file system, you can't use Rails' built in asset cacher, or libraries like `asset_packager`.  They rely on the ability to write to the file system in the production environment.

Some libraries solve this by patching `asset_packager` to redirect css/js urls to the `/tmp` directory using Rack middleware.  The `/tmp` directory is about the only place Heroku lets you write to the file system in.  The main issue with this approach is that all requests for stylesheets and javascripts must pass through Rack, which potentially _doubles_ response time.  Take a look at the [asset loading performance comparison with different Ruby stacks](http://www.ridingtheclutch.com/2009/07/13/the-ultimate-ruby-performance-test-part-1.html).

The best possible way to manage your production assets is to have everything completely static, minimized, and gzipped.  This means no passing through Rack, no redirects, no inline X.  Then whenever you deploy, you run it through Compressible and it will optimize your development assets for production.

As such, Compressible compresses all assets before you push to Heroku, so a) you never write to the Heroku file system, and b) you don't have slow down the request with application or middleware layers.

## Resources

- [http://scoop.simplyexcited.co.uk/2009/11/24/yui-compressor-vs-google-closure-compiler-for-javascript-compression/](http://scoop.simplyexcited.co.uk/2009/11/24/yui-compressor-vs-google-closure-compiler-for-javascript-compression/)

### Alternatives

- [AssetPackager](http://github.com/sbecker/asset_packager): Needs patch to work on Heroku. Uses something other than YUICompressor and Google Closure.

<cite>copyright [@viatropos](http://viatropos.com) 2010</cite>