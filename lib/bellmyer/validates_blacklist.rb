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
        class_inheritable_accessor :blacklist_file
        class_inheritable_accessor :blacklist_attributes
        
        extend ClassMethods
        include InstanceMethods

        validate :model_blacklists

      end
      
      self.options = options
      self.model = self.to_s.underscore
      self.blacklist_file = "#{RAILS_ROOT}/config/blacklists/#{self.to_s.underscore}_blacklist.yml"
    end
    
    module ClassMethods
      def blacklist(attribute, value, message = nil)
        attribute = attribute.to_s

        load_blacklist
        self.blacklist_attributes[attribute] ||= []
        if message.nil?
          self.blacklist_attributes[attribute].reject!{|a| a.is_a?(Array) ? a.first == value : a == value}
          self.blacklist_attributes[attribute] << value
        else
          self.blacklist_attributes[attribute].reject!{|a| a.is_a?(Array) ? a.first == value : a == value}
          self.blacklist_attributes[attribute] << [value, message]
        end
        save_blacklist
      end
      
      def unblacklist(attribute, value)
        attribute = attribute.to_s
        
        load_blacklist
        self.blacklist_attributes[attribute].reject!{|a| a.is_a?(Array) ? a.first == value : a == value}
        save_blacklist
      end
      
      def load_blacklist
        self.blacklist_attributes = YAML.load_file(self.blacklist_file) || {}
      end
      
      def save_blacklist
        File.open(self.blacklist_file, 'w'){|f| YAML.dump(self.blacklist_attributes, f)}
      end
    end
    
    module InstanceMethods
      
      
      protected
      
      def model_blacklists
        # Load blacklist #
        if attributes = self.class.load_blacklist
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
