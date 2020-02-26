# Rails.application.config.restricting_rules is the system-wide variable-accessible list of access rules
# We update this every time access rules is updated we must update the config
# Using this system reduces queries to the database for access rules substantially.
Rails.application.config.occurrence_templates = OccurrenceTemplate
                                                  .preload(:children)
                                                  .where(archived: false, parent_id: nil)
                                                  .map{|x| [x.title, x]}.to_h
                                                  .map{|key, value| key.split(',').map{|x| [x, value]}.to_h}
                                                  .reduce Hash.new, :merge rescue ['error']
