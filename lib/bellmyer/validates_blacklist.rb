module Bellmyer
  module ValidatesBlacklist
    require 'yaml'

    def validates_blacklist(options = {})
      options.reverse_merge!(
        :message  => 'is not allowed.',
        :attributes => {}
      )

      unless included_modules.include? InstanceMethods
        class_inheritable_accessor :options
        class_inheritable_accessor :model
        
        extend ClassMethods
        include InstanceMethods

        validate :model_blacklists

      end
      
      self.options = options
        self.model = self.to_s.underscore
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
        blacklist = "#{RAILS_ROOT}/config/blacklists/#{self.class.to_s.underscore}_blacklist.yml"
        
        # Load blacklist #
        if attributes = File.open(blacklist){|f| YAML::load(f)}
          # Cycle through attributes #
          attributes.each do |attribute, stops|
            attribute = attribute.to_sym
            
            stops.each do |stop|
              stop_name = stop.is_a?(Array) ? stop.first : stop
              stop_message = stop.is_a?(Array) ? stop.last : self.options[:attributes][attribute] || self.options[:message]
              
              # regexp #
              if !self.send(attribute).nil? && stop_name =~ /^\//
                errors.add(attribute, stop_message) if eval("self.#{attribute} =~ #{stop_name}")
              elsif !self.send(attribute).nil? && stop_name =~ /^(\<|\>|!|=)/
                errors.add(attribute, stop_message) if eval("self.#{attribute} #{stop_name}")
              else
                errors.add(attribute, stop_message) if self.send(attribute).to_s == stop_name
              end
            end
          end
        end
      end
    end
  end
end
