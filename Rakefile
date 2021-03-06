require 'rake'
require "rake/rdoctask"
require 'rake/gempackagetask'

# http://docs.rubygems.org/read/chapter/20
spec = Gem::Specification.new do |s|
  s.name              = "compressible"
  s.version           = "0.0.3"
  s.author            = "Lance Pollard"
  s.summary           = "Compressible: Quick asset compression for Ruby - Perfect for Heroku"
  s.homepage          = "http://github.com/viatropos/compressible"
  s.email             = "lancejpollard@gmail.com"
  s.description       = "Quick asset compression for Ruby - Perfect for Heroku"
  s.has_rdoc          = true
  s.rubyforge_project = "compressible"
  s.platform          = Gem::Platform::RUBY
  s.files             = %w(README.markdown Rakefile init.rb MIT-LICENSE) + Dir["{lib,rails,test}/**/*"] - Dir["test/tmp"]
  s.require_path      = "lib"
  s.add_dependency("activesupport", ">= 2.3.5")
  s.add_dependency("yui-compressor")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec    = spec
  pkg.package_dir = "pkg"
end

desc "Create .gemspec file (useful for github)"
task :gemspec do
  File.open("pkg/#{spec.name}.gemspec", "w") do |f|
    f.puts spec.to_ruby
  end
end

desc "Build the gem into the current directory"
task :gem => :gemspec do
  `gem build pkg/#{spec.name}.gemspec`
end

desc "Publish gem to rubygems"
task :publish => [:package] do
  %x[gem push pkg/#{spec.name}-#{spec.version}.gem]
end

desc "Print a list of the files to be put into the gem"
task :manifest do
  File.open("Manifest", "w") do |f|
    spec.files.each do |file|
      f.puts file
    end
  end
end

desc "Install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{spec.name}-#{spec.version} --no-ri --no-rdoc}
end

desc "Generate the rdoc"
Rake::RDocTask.new do |rdoc|
  files = ["README.markdown", "lib/**/*.rb"]
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.markdown"
  rdoc.title = spec.summary
end

task :yank do
  `gem yank #{spec.name} -v #{spec.version}`
end

namespace :hookify do
  
  task :pre_commit do
  end
  
end#
