require 'rubygems'
require 'rake'
require 'yui/compressor'

namespace :compress do
  
  desc "Compress JS"
  task :js do
    Compressible.js(
      ENV["JS"].split(/,?\s+/),
      :to => ENV["TO"],
      :munge => ENV["MUNGE"].blank? || true : ENV["MUNGE"]
    )
  end
  
  desc "Compress CSS"
  task :css do
    Compressible.css(
      ENV["CSS"].split(/,?\s+/),
      :to => ENV["TO"]
    )
  end
  
  desc "Compress CSS and JS"
  task :all => [:js, :css]
  
end
