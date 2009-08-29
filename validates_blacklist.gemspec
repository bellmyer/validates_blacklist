Gem::Specification.new do |s|
  s.name = 'validates_blacklist'
  s.version = '0.1.5'
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
    "MIT-LICENSE",
    "Rakefile",
    "README",
    "validates_blacklist.gemspec",
    "generators/blacklists/templates/blacklist.yml",
    "generators/blacklists/blacklists_generator.rb",
    "lib/validates_blacklist.rb",
    "lib/bellmyer/validates_blacklist.rb",
    "test/config/blacklists/friend_with_attribute_message_blacklist.yml",
    "test/config/blacklists/friend_with_blacklist_blacklist.yml",
    "test/config/blacklists/friend_with_blank_blacklist_blacklist.yml",
    "test/config/blacklists/friend_with_custom_message_blacklist.yml",
    "test/config/blacklists/template.yml",
    "test/test_helper.rb",
    "test/validates_blacklist_test.rb"
  ]
  
  s.test_files = ["test/validates_blacklist_test.rb"]
end
