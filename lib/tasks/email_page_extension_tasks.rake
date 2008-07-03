namespace :radiant do
  namespace :extensions do
    namespace :email_page do
      
      desc "Runs the migration of the Email Page extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          EmailPageExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          EmailPageExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Email Page to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[EmailPageExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(EmailPageExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
