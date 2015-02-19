Gem::Specification.new do |gem|
  gem.name        = 'scru'
  gem.version     = '0.0.0'
  gem.executables = ['scru']
  gem.summary     = 'Sync scripts on a drive to RightScale'
  gem.authors     = ['RightScale']
  gem.files       = `git ls-files`.split(' ')
  gem.platform    = Gem::Platform::RUBY
end
