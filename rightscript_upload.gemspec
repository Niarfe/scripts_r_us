Gem::Specification.new do |gem|
  gem.name        = 'rightscript_upload'
  gem.version     = '0.0.0'
  gem.executables = ['rightscript_upload']
  gem.summary     = 'Sync scripts on a drive to RightScale'
  gem.authors     = ['RightScale']
  gem.files       = `git ls-files`.split(' ')
  gem.platform    = Gem::Platform::RUBY
  gem.add_runtime_dependency 'thor'
end
