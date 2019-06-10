namespace :version_1_0_3 do

  task :run_all_tasks => :environment do
    Rake::Task["version_1_0_3:risk_matrix_transform"].invoke()
    Rake::Task["version_1_0_3:add_access_controls"].invoke()
    Rake::Task["version_1_0_3:populate_custom_options"].invoke()
    Rake::Task["version_1_0_3:populate_created_by"].invoke()
  end

end

