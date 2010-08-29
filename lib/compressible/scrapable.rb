class Compressible
  module Scrapable
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def remote?(path)
        !!(path =~ /^http(?:s)?/)
      end
      
      # takes remote `*paths` and writes them into a tmp local directory
      # ".compressible".  It will delete this directory immediately by default,
      # unless you want to cache assets you probably wont need to keep re-compressing.
      # not yet implemented.
      def localize(type, *paths)
        Dir.mkdir(tmp) unless File.exists?(tmp)
        local_paths = paths.map do |path|
          if remote?(path)
            local = File.join(tmp, File.basename(path))
            File.open(local, "w+") do |file|
              begin
                puts "Downloading... #{path}" if Compressible::SAY == true
                file.puts read(type, path)
              rescue Exception => e
                paths.delete(path)
                puts "#{e.message}: #{path}"
              end
            end
            [local, path]
          else
            [path, path]
          end
        end
      end
      
      def remote_path(domain, path, asset)
        # full
        if asset =~ /^http(?:s)?:\/\//
          asset
        # absolute
        elsif asset =~ /^\//
          asset = "#{domain}#{asset}"
        # relative
        else
          asset = "#{domain}#{path}/#{asset}"
        end
      end
      
      # returns css and javascripts {:js => [], :css => []}
      # requires nokogiri
      def scrape(page)
        require 'nokogiri'
        url = URI.parse(page)
        domain =   "#{url.scheme}://#{url.host}"
        domain <<  ":#{url.port.to_s}"
        path = url.path.squeeze("/")
        html = Nokogiri::HTML(open(page).read)
        scripts = []
        
        html.css("script").each do |script|
          next if script["src"].blank?
          scripts << remote_path(domain, path, script["src"])
        end
        
        csses = []
        
        html.css("link[rel=stylesheet]").each do |css|
          next if css["href"].blank?
          csses << remote_path(domain, path, css["href"])
        end
        
        {:js => scripts, :css => csses}
      end
      
      def destroy(*paths)
        Dir.entries(tmp)[2..-1].each do |path|
          File.delete(File.join(tmp, path))
        end
        Dir.delete(tmp) if File.exists?(tmp)
      end
    end
  end
end
