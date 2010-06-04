module Compressible::ViewHelpers
  
  def compressible_stylesheet_tag(*keys)
    Compressible.stylesheets_for(*keys).collect do |asset|
      stylesheet_link_tag(asset)
    end.join("\n").html_safe
  end
  
  def compressible_javascript_tag(*keys)
    Compressible.javascripts_for(*keys).collect do |asset|
      javascript_include_tag(asset)
    end.join("\n").html_safe
  end
  
end

ActionView::Base.send(:include, Compressible::ViewHelpers) if defined?(ActionView)
