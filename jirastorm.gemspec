lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'jirastorm'
  spec.version       = '0.1.0'
  spec.authors       = ['David Danzilio', 'Jim Cuff']
  spec.email         = ['david@danzil.io']
  spec.summary       = 'A utility to sync issues between JIRA and Stormboard.'
  spec.description   = 'Syncs issues between JIRA and Stormboard.'
  spec.homepage      = 'http://github.com/ddanzilio/jirastorm'
  spec.license       = 'Apache 2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'

  spec.add_runtime_dependency 'thor'
end
