Gem::Specification.new do |s|
  s.name = 'validates_blacklist'
  s.version = '0.1.1'
  s.date = '2009-08-26'
  
  s.summary = "Allows models to be validated against yaml-based blacklists"
  s.description = ""
  
  s.authors = ['Jaime Bellmyer']
  s.email = 'ruby@bellmyer.com'
  s.homepage = 'http://github.com/bellmyer/validates_blacklist'
  
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

  s.add_dependency 'rails', ['>= 2.1']
  
   s.files = [
    "README",
    "validates_blacklist.gemspec",
    "lib/bellmyer-validates_blacklist.rb",
    "lib/active_record/validates/blacklist.rb",
  ]
  
  s.test_files = ["test/blacklist_test.rb"]

end
