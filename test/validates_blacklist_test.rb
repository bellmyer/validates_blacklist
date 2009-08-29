require 'test/unit'
require 'rubygems'
require 'active_record'
require 'ftools'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../lib/validates_blacklist'
 
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
 
# AR keeps printing annoying schema statements
$stdout = StringIO.new

RAILS_ROOT = File.dirname(__FILE__)

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :friends do |t|
      t.string  :name
      t.string  :email
      t.integer :age
      t.integer :net_worth
      t.string  :school
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Friend < ActiveRecord::Base
end

class FriendWithBlacklist < Friend
  validates_blacklist
end

class FriendWithBlacklistTest < Test::Unit::TestCase
  def setup
    setup_db
  end
  
  def teardown
    teardown_db
  end
  
  def test_should_fail_validation_on_exact_string_match
    friend = FriendWithBlacklist.new(:name => 'Stinky Pete')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?("is not allowed.")
  end
  
  def test_should_fail_validation_on_regexp_match
    friend = FriendWithBlacklist.new(:name => 'Handsome Pete')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?("is not allowed.")
  end
  
  def test_should_fail_validation_on_custom_message
    friend = FriendWithBlacklist.new(:name => 'Vanessa')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?("is not allowed after ditching my b-day party")
  end
  
  def test_should_fail_validation_on_less_than_match
    friend = FriendWithBlacklist.new(:age => 12)
    assert !friend.valid?
    assert friend.errors.invalid?(:age)
    assert friend.errors.on(:age).include?("is too young to party.")
  end
  
  def test_should_fail_validation_on_greater_than_match
    friend = FriendWithBlacklist.new(:age => 55)
    assert !friend.valid?
    assert friend.errors.invalid?(:age)
    assert friend.errors.on(:age).include?("is too old and pervy!")
  end
  
  def test_should_fail_validation_on_greater_than_or_equal_match
    friend = FriendWithBlacklist.new(:net_worth => 150_000)
    assert !friend.valid?
    assert friend.errors.invalid?(:net_worth)
    assert friend.errors.on(:net_worth).include?('is too rich.')
  end
  
  def test_should_fail_validation_on_less_than_or_equal_match
    friend = FriendWithBlacklist.new(:net_worth => 50_000)
    assert !friend.valid?
    assert friend.errors.invalid?(:net_worth)
    assert friend.errors.on(:net_worth).include?('is too poor.')
  end
  
  def test_should_fail_validation_on_explicit_nonregexp
    friend = FriendWithBlacklist.new(:school => 'Mouthbreather Academy')
    assert !friend.valid?
    assert friend.errors.invalid?(:school)
    assert friend.errors.on(:school).include?("is not Valley High School!")
  end
  
  def test_should_fail_validation_on_explicit_regexp
    friend = FriendWithBlacklist.new(:name => 'Papa Smurf')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?("is not allowed to be a smurf!")
  end
end

class FriendWithCustomMessage < Friend
  validates_blacklist :message => "has left the building."
end

class FriendWithCustomMessageTest < Test::Unit::TestCase
  def setup
    setup_db
  end
  
  def teardown
    teardown_db
  end
  
  def test_global_custom_message_fails_validation_on_exact_string_match
    friend = FriendWithCustomMessage.new(:name => 'Stinky Pete')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?("has left the building.")
  end
end

class FriendWithAttributeMessage < Friend
  validates_blacklist :message => "has left the building.", :attributes => {:email => 'looks spammy'}
end

class FriendWithAttributeMessageTest < Test::Unit::TestCase
  def setup
    setup_db
  end
  
  def teardown
    teardown_db
  end
  
  def test_attribute_message_fails_validation_on_exact_string_match_with_global_message
    friend = FriendWithAttributeMessage.new(:name => 'Stinky Pete')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?("has left the building.")
  end
  
  def test_attribute_message_fails_validation_on_exact_string_match_with_attrib_message
    friend = FriendWithAttributeMessage.new(:email => 'stinky_pete@gmail.com')
    assert !friend.valid?
    assert friend.errors.invalid?(:email)
    assert friend.errors.on(:email).include?('looks spammy')
  end
end

class FriendWithBlankBlacklist < Friend
  validates_blacklist
end

class FriendWithBlankBlacklistTest < Test::Unit::TestCase
  def setup
    setup_db
  end
  
  def teardown
    teardown_db
  end
  
  def test_should_not_fail
    friend = FriendWithBlankBlacklist.new(:name => 'Stinky Pete')
    assert friend.valid?
  end
end

class FriendUpdateable < Friend
  validates_blacklist
end

class FriendUpdateableTest < Test::Unit::TestCase
  def setup
    setup_db
    File.copy("#{RAILS_ROOT}/config/blacklists/template.yml", "#{RAILS_ROOT}/config/blacklists/friend_updateable_blacklist.yml")
  end
  
  def teardown
    teardown_db
    File.unlink("#{RAILS_ROOT}/config/blacklists/friend_updateable_blacklist.yml")
  end
  
  def test_should_add_a_new_blacklist_item_without_message
    FriendUpdateable.blacklist(:name, 'terrible')
    
    friend = FriendUpdateable.new(:name => 'terrible')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?('is not allowed.')
  end
  
  def test_should_add_a_new_blacklist_item_with_message
    FriendUpdateable.blacklist(:name, 'terrible', "is terrible.")

    friend = FriendUpdateable.new(:name => 'terrible')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?('is terrible.')
  end
  
  def test_should_update_an_existing_blacklist_item_changing_message_without_adding_item
    FriendUpdateable.blacklist(:name, 'Vanessa', "is terrible.")

    friend = FriendUpdateable.new(:name => 'Vanessa')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?('is terrible.')
    
    list = FriendUpdateable.load_blacklist
    assert_equal 1, list['name'].select{|node| node.is_a?(Array) ? node.first == 'Vanessa' : node == 'Vanessa'}.size
  end
  
  def test_should_update_an_existing_blacklist_item_adding_message_without_adding_item
    FriendUpdateable.blacklist(:name, 'Stinky Pete', "is terrible.")

    friend = FriendUpdateable.new(:name => 'Stinky Pete')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?('is terrible.')
    
    list = FriendUpdateable.load_blacklist
    assert_equal 1, list['name'].select{|node| node.is_a?(Array) ? node.first == 'Stinky Pete' : node == 'Stinky Pete'}.size
  end
  
  def test_should_update_an_existing_blacklist_item_removing_message_without_adding_item
    FriendUpdateable.blacklist(:name, 'Vanessa')

    friend = FriendUpdateable.new(:name => 'Vanessa')
    assert !friend.valid?
    assert friend.errors.invalid?(:name)
    assert friend.errors.on(:name).include?('is not allowed.')
    
    list = FriendUpdateable.load_blacklist
    assert_equal 1, list['name'].select{|node| node.is_a?(Array) ? node.first == 'Vanessa' : node == 'Vanessa'}.size
  end
end
