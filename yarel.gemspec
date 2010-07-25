Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'yarel'
  s.version     = "0.0.1"
  s.homepage    = 'http://github.com/selvakn/yarel'
  s.summary     = 'Object-relational mapper for Yahoo Query Language'
  s.description = 'Object-relational mapper for Yahoo Query Language - A Object Relation Mapper for YQL in ruby, very similar to ActiveRecord 3.0.0 with chainability and lazy evaluation of queries'

  s.required_ruby_version = '>= 1.8.7'

  s.authors     = ['Selvakumar Natesan', 'Sharanya Sennimalai']
  s.email       = ['k.n.selvakumar@gmail.com', 's.sharanya@gmail.com']

  s.files        = Dir['readme.rextile', 'lib/**/*']
  s.require_path = 'lib'

  s.add_dependency('activesupport', '>= 3.0.0.beta4')
  s.add_dependency('activemodel',   '>= 3.0.0.beta4')
  s.add_development_dependency('rspec')
  s.test_files = Dir.glob('spec/**/*.rb')
end
