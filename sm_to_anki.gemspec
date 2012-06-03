# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sm_to_anki/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["yangchenyun@gmail.com"]
  gem.email         = ["yangchenyun@gmail.com"]
  gem.description   = %q{An ruby script to transform supermemo UX courses to anki courses}
  gem.summary       = %q{Ruby gem converts sm exercises to anki files}
  gem.homepage      = "http://localhost"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sm_to_anki"
  gem.require_paths = ["lib"]
  gem.version       = SmToAnki::VERSION

  gem.add_dependency "nokogiri", "~> 1.5.0"
  gem.add_development_dependency 'minitest', '~> 3.0'
end
