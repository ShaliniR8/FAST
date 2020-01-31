desc "Migrate RootCause to Occurrence"
task :migrate_occurrence_root_cause => :environment do

  # reset Occurrence Template table
  ActiveRecord::Base.connection.execute("TRUNCATE  occurrences")

  records = RootCause.all

  records.each do |record|
    value = CauseOption.find(record.cause_option_id).name
    title = CauseOption.find(record.cause_option_id).cause_options[0].name

    if OccurrenceTemplate.find_by_title(title).nil?
      p "#{record.owner.class.name} #{record.owner.id}"
      p 'Occurrence template: <' + title + '> is missing'
    elsif value == 'Other'
      if record.owner.nil?
        p 'missing.....'
        p record.id
      else
        template_id = OccurrenceTemplate.find_by_title(title).id
        Occurrence.create(template_id: template_id, owner_id: record.owner_id, owner_type: record.owner_type, value: record.get_value)
      end
    else
      template_id = OccurrenceTemplate.find_by_title(title).id
      Occurrence.create(template_id: template_id, owner_id: record.owner_id, owner_type: record.owner_type, value: value)
    end
  end
end
