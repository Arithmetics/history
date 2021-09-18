# EXAMPLES:
# with quotes!
# rake 'restore_and_dump:db_dump[test_xx]'
# rake 'restore_and_dump:db_restore[test_xx]'

namespace :restore_and_dump do
  db_name = "history_development"
  root_folder = "#{Rails.root}/psql_backups/"

  desc "create database backup"

  task :db_dump, [:backup_name] => [:environment] do |t, args|
    system "pg_dump -Fc --no-owner --dbname=#{db_name} > #{root_folder}#{args[:backup_name]}.tar"
  end

  desc "restore from database backup"
  task :db_restore, [:backup_name] => [:environment] do |t, args|
    system "pg_restore --clean --no-owner --dbname=#{db_name} #{root_folder}#{args[:backup_name]}.tar"
  end
end
