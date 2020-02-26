# Rails.application.config.restricting_rules is the system-wide variable-accessible list of access rules
# We update this every time access rules is updated we must update the config
# Using this system reduces queries to the database for access rules substantially.
Rails.application.config.custom_options = CustomOption.all.map{|x| [x.title, (x.options.split(';') rescue [''])]}.to_h
