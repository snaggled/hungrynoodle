# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hungrynoodle}
  s.version = "0.0.3"     
  s.require_path = '.'
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philip Mcmahon"]
  s.date = %q{2011-01-21}
  s.email = %q{philip@packetnode.com}
  s.files = [
    "hungrynoodle.rb",
    "README.rdoc"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/snaggled/hungrynoodle}
  s.summary = %q{Library that provides a simple mechanism to find and cache a list of files on your system (much like slocate).}
  s.add_dependency(%q<sqlite3>, [">= 1.3.3"])
  s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.3"])
end