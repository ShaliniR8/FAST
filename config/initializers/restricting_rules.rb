# Rails.application.config.restricting_rules is the system-wide variable-accessible list of access rules
# We update this every time access rules is updated we must update the config
# Using this system reduces queries to the database for access rules substantially.
restricting_rules = Hash.new{ |h, k| h[k] = [] }
AccessControl.all.each do |acs|
  restricting_rules[acs.entry] << acs.action
end
restricting_rules.update(restricting_rules) { |key, val| val.uniq }
Rails.application.config.restricting_rules = restricting_rules
