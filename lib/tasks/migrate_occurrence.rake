desc "Migrate RootCause to Occurrence"
task :migrate_occurrence_root_cause => :environment do

  # reset Occurrence Template table
  ActiveRecord::Base.connection.execute("TRUNCATE  occurrences")

  records = RootCause.all  #.where(owner_id: 91) # TEST: Report id: 91 first!

  records.each do |record|
    value = CauseOption.where(id: record.cause_option_id)[0].name
    title = CauseOption.where(id: record.cause_option_id)[0].cause_options[0].name
    template_id = OccurrenceTemplate.where(title: title)[0].id

    Occurrence.create(template_id: template_id, owner_id: record.owner_id, owner_type: record.owner_type, value: value)
  end
end


task :migrate_occurrence_cause => :environment do

end
