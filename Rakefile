require "bundler/gem_tasks"
require "rake/testtask"
require "rspec/core/rake_task"
require 'yard'
p base_path = File.expand_path('..', __FILE__)
p basename = File.basename(base_path)

task :default do
  system 'rake -T'
end

desc "spec"
task :spec do
  RSpec::Core::RakeTask.new(:spec)
end

desc "make documents by yard"
task :yard do
=begin
  files = Dir.entries('docs')
  files.each{|file|
    name=file.split('.')
    if name[1]=='hiki' then
      p command="hiki2md docs/#{name[0]}.hiki > #{basename}.wiki/#{name[0]}.md"
      system command
    end
  }
  system "cp #{basename}.wiki/README_ja.md README.md"
  system "cp #{basename}.wiki/README_ja.md #{basename}.wiki/Home.md"
  system "cp docs/*.gif #{basename}.wiki"
  system "cp docs/*.gif doc"
  system "cp docs/*.png #{basename}.wiki"
  system "cp docs/*.png doc"
=end
  YARD::Rake::YardocTask.new
end

desc "submit files on github."
task :update =>[:setenv] do
  p "emacs ./lib/#{basename}/version.rb"
  system "emacs ./lib/#{basename}/version.rb"
  system 'git add -A'
  system 'git commit'
  system 'git push -u origin master'
#  system 'bundle exec rake release'
end

desc "setenv for release from Kwansei gakuin."
task :setenv do
  p command='setenv HTTP_PROXY http://proxy.ksc.kwansei.ac.jp:8080'
  system command
  p command='setenv HTTPS_PROXY http://proxy.ksc.kwansei.ac.jp:8080'
  system command
end

