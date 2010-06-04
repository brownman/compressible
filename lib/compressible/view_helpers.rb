module Compressible::ViewHelpers
  
  def compressible_stylesheet_tag(*keys)
    Compressible.stylesheets_for(*keys).collect do |asset|
      stylesheet_link_tag(asset)
    end.join("\n").send(safe_method)
  end
  
  def compressible_javascript_tag(*keys)
    Compressible.javascripts_for(*keys).collect do |asset|
      javascript_include_tag(asset)
    end.join("\n").send(safe_method)
  end
  
  private
    def safe_method
      if "".respond_to?(:html_safe)
        return :html_safe
      elsif "".respond_to?(:html_safe!)
        return :html_safe!
      else
        return :to_s
      end
    end
  
end

ActionView::Base.send(:include, Compressible::ViewHelpers) if defined?(ActionView)
