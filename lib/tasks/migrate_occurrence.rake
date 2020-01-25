desc "Migrate RootCause to Occurrence"
task :migrate_occurrence_root_cause => :environment do

  # reset Occurrence Template table
  ActiveRecord::Base.connection.execute("TRUNCATE  occurrences")

  records = RootCause.all

  records.each do |record|
    value = CauseOption.find(record.cause_option_id).name
    title = CauseOption.where(id: record.cause_option_id)[0].cause_options[0].name

    if OccurrenceTemplate.where(title: title)[0].nil?
      p "#{record.owner.class.name} #{record.owner.id}"
      p 'Occurrence template: <' + title + '> is missing'
    else
      template_id = OccurrenceTemplate.where(title: title)[0].id
      Occurrence.create(template_id: template_id, owner_id: record.owner_id, owner_type: record.owner_type, value: value)
    end
  end
end
