module ActiveRecord
  module Validates #:nodoc:
    module Blacklist #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        validates_blacklist(options = {})
          options.reverse_merge!(:message => 'is not allowed')
          
          include ActiveRecord::Validates::Blacklist::InstanceMethods
        end
      end

      module InstanceMethods
        def blacklist(attribute, value, message = nil)
          puts "blacklisted!"
        end
        
        def unblacklist(attribute, value)
          puts "unblacklisted!"
        end
      end 
    end
  end
end
