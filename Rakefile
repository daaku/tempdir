require 'rubygems'
require 'rake/gempackagetask'

GEM = 'tempdir'
GEM_VERSION = '0.2.0'
AUTHOR = 'Naitik Shah'
EMAIL = 'naitik.shah@yahoo.com'
HOMEPAGE = 'http://github.com/nshah/tempdir'
SUMMARY = 'Tempfile like functionality for directories'

spec = Gem::Specification.new do |s|
  s.name         = GEM
  s.version      = GEM_VERSION
  s.platform     = Gem::Platform::RUBY
  s.has_rdoc     = true
  s.summary      = SUMMARY
  s.description  = s.summary
  s.author       = AUTHOR
  s.email        = EMAIL
  s.homepage     = HOMEPAGE

  s.require_path = 'lib'
  s.files        = %w(LICENSE README Rakefile TODO) + Dir.glob('{lib,specs}/**/*')
  s.extra_rdoc_files = ['README', 'LICENSE', 'TODO']
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install the gem file #{GEM}-#{GEM_VERSION}.gem"
task :install => [:package] do
  sh %{gem install pkg/#{GEM}-#{GEM_VERSION}}
end
