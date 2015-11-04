lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'jirastorm'
  spec.version       = '0.1.0'
  spec.authors       = ['David Danzilio', 'Jim Cuff']
  spec.email         = ['david@danzilio.net']
  spec.summary       = 'A utility to sync issues between JIRA and Stormboard.'
  spec.description   = 'Syncs issues between JIRA and Stormboard.'
  spec.homepage      = 'http://github.com/danzilio/jirastorm'
  spec.license       = 'Apache 2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'

  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'mixlib-config', '~> 2.2'
  spec.add_runtime_dependency 'jira-ruby', '~> 0.1.16'
  spec.add_runtime_dependency 'rest-client', '~> 1.8'
end
