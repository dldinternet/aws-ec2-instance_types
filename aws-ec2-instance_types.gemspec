# -*- encoding: utf-8 -*-

require File.expand_path('../lib/aws/ec2/instance_types/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'aws-ec2-instance_types'
  gem.version       = Aws::Ec2::InstanceTypes::VERSION
  gem.summary       =
  gem.description   = %q{Retrieve an up to date list of valid AWS EC2 Instance Types directly from Amazon Web Services official site.}
  gem.license       = 'Apachev2'
  gem.authors       = ['Christo De Lange']
  gem.email         = 'rubygems@dldinternet.com'
  gem.homepage      = 'https://rubygems.org/gems/aws-ec2-instance_types'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'

  gem.add_runtime_dependency(%q<mechanize>, ['>= 2.7.2'])
  gem.add_runtime_dependency(%q<nokogiri>, ['>= 1.5.0'])
  gem.add_runtime_dependency(%q<awesome_print>, ['>= 1.2.0'])
  gem.add_runtime_dependency(%q<colorize>, ['>= 0.7.2'])

end
