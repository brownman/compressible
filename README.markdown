# Compressible

Ready-to-go Asset Compression for Ruby, using the YUICompressor.

    sudo gem install compressible
    
# Usage

## Configuration

There are a few ways you can configure this

### 1. Initializers

Inside an initializer such as `config/compressible.rb`:

    Compressible.stylesheets(
      :production_cache => %w(reset background footer list),
      :typography => %w(forms headers basic_text)
    )
    Compressible.javascripts(
      :production_cache => %w(animations effects dragdrop)
    )
    
    # or
    Compressible.assets(
      :stylesheets => {
        :production_cache => %w(reset background footer list),
        :typography => %w(forms headers basic_text)
      }
      :javascripts => {
        :production_cache => %w(animations effects dragdrop)
      }
    )
    
    # or one at a time
    Compressible.stylesheet(
      :production_cache => %w(reset background footer list)
    )
    Compressible.stylesheet(
      :typography => %w(forms headers basic_text)
    )

Each of those methods have plenty of aliases to be more descriptive and more concise, respectively:

- `stylesheets`: `add_stylesheets`
- `javascripts`: `add_javascripts`
- `stylesheet`: `add_stylesheet`, `css`
- `javascript`: `add_javascript`, `js`

Or you can call them generically:

    Compressible.assets(:stylesheet)
    Compressible.assets(:javascript)
    
### 2. Yaml

You can specify these same configuration options using Yaml:

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
    
## Views

Add this to your views:

    compressible_stylesheet_tag("production_cache", "typography")
    compressible_javascript_tag("production_cache")

By default, it will use non-compressed stylesheets when `Rails.env == "development"`, and the compressed stylesheets when `Rails.env == "production"`.

To tell it you want to use the cached in a different environment, you can specify it like this:

    compressible_stylesheet_tag("production_cache", :environments => ["production", "staging"])

## Awesome Assets for Heroku

Because Heroku is a Read-Only file system, you can't use Rails' built in asset cacher, or libraries like `asset_packager`.  They rely on the ability to write to the file system in the production environment.

Some libraries solve this by patching `asset_packager` to redirect css/js urls to the `/tmp` directory using Rack middleware.  The `/tmp` directory is about the only place Heroku lets you write to the file system in.  The main issue with this approach is that all requests for stylesheets and javascripts must pass through Rack, which potentially _doubles_ response time.  Take a look at the [asset loading performance comparison in with different Ruby stacks](http://www.ridingtheclutch.com/2009/07/13/the-ultimate-ruby-performance-test-part-1.html).

As such, Compressible compresses all assets before you push to Heroku, so a) you never write to the Heroku file system, and b) you don't have slow down the request with application or middleware layers.  It does this with _git hooks_.  Every time you commit, a `pre-commit` hook runs which re-compresses your assets.  That means whenever you push, your assets are ready for production.

This is configurable.  It relies on the [`hookify`](http://github.com/viatropos/hookify) gem.

    sudo gem install hookify
    cd my-rails-app
    hookify pre-commit
    
That creates a ruby script for you were you can define what you want to run when.  In our case, we want to run:

    Compressible.assets(
      :stylesheets => {
        :production_cache => %w(reset background footer list),
        :typography => %w(forms headers basic_text)
      }
      :javascripts => {
        :production_cache => %w(animations effects dragdrop)
      }
    )
    
Very cool.