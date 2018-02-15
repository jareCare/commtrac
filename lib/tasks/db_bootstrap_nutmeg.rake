namespace :db do

  namespace :bootstrap do

    desc "Load Nutmeg's initial admin and companies"
    task :nutmeg => :environment do 
      require 'active_record/fixtures'
      fixtures = FileList['db/bootstrap/nutmeg/*.yml']
      tables = fixtures.collect {|each| File.basename each, '.yml'}
      Fixtures.create_fixtures 'db/bootstrap/nutmeg', tables
    end

  end 

end
