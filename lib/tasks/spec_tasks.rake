task :run_spec do
  if (ENV['RAILS_ENV'] == "test")
    Rake::Task['spec'].invoke
  else
    system("rake spec RAILS_ENV=test")
  end
end
