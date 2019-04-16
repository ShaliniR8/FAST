namespace :recurring do

  task :generate_recurrent_forms => :environment do
    desc 'Generate upcoming forms from recurrent items'

    puts 'BEGIN Generating Recurrent Forms:'
    active_recurring = Recurrence.where('(end_date > ? OR end_date IS NULL) AND next_date < ?',
        DateTime.now, DateTime.now)
    puts "Checking #{active_recurring.count} recurrences:"
    active_recurring.each do |recurrence|
      type = Object.const_get(recurrence.form_type)
      next_form = type.find(recurrence.next_id)
      if next_form.status == "Completed"
        puts "Generating #{type.name} for Recurrence ##{recurrence.id}"
        next_date = recurrence.next_date +
            (Recurrence.month_count[recurrence.frequency])[:number].months
        template = type.find(recurrence.template_id)
        next_form = template.clone
        next_form.completion = next_date
        if next_form.save!
          recurrence.next_date = next_date
          recurrence.next_id = next_form.id
          if recurrence.save!
            puts "New #{type.name} generated: #{type.name} #{next_form.id}: scheduled for completion on #{next_date}"
          end
        end
      end
    end
    puts 'FINISH Generating Recurrent Forms:'
  end
end
