desc 'Updates legacy user account types (pilot, ground, analyst)'
task :update_legacy_user_accounts => :environment do
  puts 'UPDATING LEGACY USER ACCOUNT TYPES...'
  legacy_account_types = ['Pilot', 'Ground', 'Analyst']
  User.transaction do
    User.where(level: legacy_account_types).each { |u| u.update_attributes!(level: 'Staff') }
  end
  puts 'DONE'
end
