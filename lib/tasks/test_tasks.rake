namespace :test do
  task :spec do
    if (ENV['RAILS_ENV'] == "test")
      Rake::Task['spec'].invoke
    else
      system("rake test:spec RAILS_ENV=test")
    end
  end

  namespace :db do
    task :setup do
      if (ENV['RAILS_ENV'] == "test")
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
      else
        system("rake test:db:setup RAILS_ENV=test")
      end
    end
  end
end
