desc 'Updates \'Inflight\' Tempaltes\' employee group to \'Inflight\''
task :update_inflight_templates => :environment do
  puts 'UPDATING INFLIGHT TEMPLATES\' EMP GROUP TO \'INFLIGHT\'...'
  Template.all.select{ |t| t.name.downcase.include?('inflight') }.each{ |temp| temp.update_attributes(emp_group: 'inflight') }
  puts 'DONE'
end
