class BlacklistsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory 'config/blacklists'
      
      Dir["#{RAILS_ROOT}/app/models/*.rb"].each do |file|
        m.file 'blacklist.yml', "config/blacklists/#{File.basename(file, '.rb')}_blacklist.yml", :collision => :skip
      end
    end
  end
end
