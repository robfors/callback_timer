Gem::Specification.new do |s|
  s.name        = 'callback_timer'
  s.version     = '0.0.1'
  s.date        = '2018-04-27'
  s.summary     = 'Create timers that support a callback.'
  s.description = 'Create cancelable timer objects that will call a given callback when time has elapsed. Implemented using a single scheduling thread.'
  s.authors     = 'Rob Fors'
  s.email       = 'mail@robfors.com'  
  s.files       = Dir.glob("{lib,spec}/**/*") + %w(LICENSE README.md)
  s.homepage    = 'https://github.com/robfors/callback_timer'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.3.0'
end
