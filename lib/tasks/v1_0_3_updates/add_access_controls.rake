namespace :version_1_0_3 do

  task :add_access_controls => :environment do
    rules = AccessControl.get_meta
    rules.each do |rule, data|
      data.each do |key, val|
        new_rule = AccessControl.new(
          :list_type => 1,
          :action => val,
          :entry => rule) if AccessControl.where(action: val, entry: rule).empty?
        new_rule.save if !new_rule.nil?
      end
    end
  end


end
