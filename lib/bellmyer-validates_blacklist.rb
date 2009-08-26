require 'active_record/validates/blacklist'
ActiveRecord::Base.class_eval { include ActiveRecord::Validates::Blacklist }
