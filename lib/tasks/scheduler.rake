desc 'This task is called by the Heroku scheduler add-on'
task :update_database => :environment do
  puts 'Updating database...'
  RetrieveExternalDb.new('http://54.174.7.121/data.sqlite').import!
  puts 'done.'
end
