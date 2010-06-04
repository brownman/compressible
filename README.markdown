# Compressible

Ready-to-go Asset Compression for Ruby, using the YUICompressor.

    sudo gem install compressible
    
# Usage

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

## Asset loading performance

http://www.ridingtheclutch.com/2009/07/13/the-ultimate-ruby-performance-test-part-1.html