namespace :test do
  task :spec do
    if (ENV['RAILS_ENV'] == "test")
      Rake::Task["spec"].execute
    else
      system("rake RAILS_ENV=test test:spec")
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
