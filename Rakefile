require "rubygems"
require "rake"
begin
  require "rspec/core/rake_task"
rescue LoadError
  desc "Run specs"
  task(:spec) { $stderr.puts '`gem install rspec` to run specs' }
else
  desc "Run all Specs"
  RSpec::Core::RakeTask.new(:spec) do |t|
  end
  
  task :default => :spec
end

desc 'Removes trailing whitespace'
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end
