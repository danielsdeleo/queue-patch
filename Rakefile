
ROOT = File.expand_path(File.dirname(__FILE__))

begin
  require 'rspec/core/rake_task'

  desc "Run all specs in spec directory"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = FileList['spec/**/*_spec.rb']
  end
rescue LoadError
  desc "can't run rspec, not installed or the wrong version"
  task :spec
end

task :default => :spec

desc "create a 1-file executable"
task :compile do
  File.open("#{ROOT}/bin/queue-patch", "w") do |f|
    f.puts "#!/usr/bin/env ruby\n"
    f.puts IO.read("#{ROOT}/lib/queue-patch.rb")
    f.puts
    f.puts 'QueuePatch::CLI.new(ARGV).run'
  end
  
end