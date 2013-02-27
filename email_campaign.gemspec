# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "email_campaign/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "email_campaign"
  s.version     = EmailCampaign::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = "Aaron Namba"
  s.email       = "aaron@biggerbird.com"
  s.homepage    = "https://github.com/anamba/email_campaign"
  s.summary     = %q{Email campaign delivery for Rails apps}
  s.description = %q{See README for details.}

  s.required_ruby_version     = '>= 1.9.3'
  s.required_rubygems_version = '>= 1.8.11'

  s.license = 'MIT'
  
  # s.rubyforge_project = "email_campaign"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "actionmailer",        "~> 3.2.12"
  s.add_dependency "mail",                "~> 2.4.4"
  s.add_dependency "net-dns",             "~> 0.7.1"
  
  s.add_development_dependency "sqlite3"
end
