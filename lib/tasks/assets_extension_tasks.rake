namespace :radiant do
  namespace :extensions do
    namespace :assets do
      
      desc "Runs the migration of the Assets extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          AssetsExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          AssetsExtension.migrator.migrate
        end
      end
    
    end
  end
end