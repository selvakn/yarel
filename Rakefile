require "rubygems"
begin
  require "spec/rake/spectask"
rescue LoadError
  desc "Run specs"
  task(:spec) { $stderr.puts '`gem install rspec` to run specs' }
else
  desc "Run all Specs"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    t.libs << "#{File.dirname(__FILE__)}/spec"
    # t.warning = true
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
  
  task :default => :spec  
end

desc 'Removes trailing whitespace'
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end
