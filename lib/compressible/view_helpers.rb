module Compressible::ViewHelpers
  
  def compressible_stylesheet_tag(*keys)
    Compressible.assets_for(:stylesheet, *keys).each do |asset|
      stylesheet_include_tag(Compressible.path_for(asset))
    end
  end
  
  def compressible_javascript_tag(*keys)
    Compressible.assets_for(:javascript, *keys).each do |asset|
      javascript_include_tag(Compressible.path_for(asset))
    end
  end
  
end

# ActionView::Helpers.send(:include, Compressible::ViewHelpers) if defined?(ActionView)
