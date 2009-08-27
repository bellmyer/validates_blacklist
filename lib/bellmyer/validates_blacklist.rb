module Bellmyer
  module ValidatesBlacklist
    def validates_blacklist(options = {})
      options.reverse_merge!(:message => 'is not allowed.')

      unless included_modules.include? InstanceMethods
        class_inheritable_accessor :options
        
        extend ClassMethods
        include InstanceMethods

        validate :model_blacklists
      end
      
      self.options = options
    end
    
    module ClassMethods
      def blacklist
        puts "blacklisted!"
      end
      
      def unblacklist
        puts "Removed from blacklist."
      end
    end
    
    module InstanceMethods
      
      
      protected
      
      def model_blacklists
        errors.add_to_base("You're blacklisted!")
      end
    end
  end
end
