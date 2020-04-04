namespace :recurring do

  desc 'Generate upcoming forms from recurrent items'
  task :generate_recurrent_forms => :environment do

    puts 'BEGIN Generating Recurrent Forms:'
    active_recurring = Recurrence.where('(end_date > ? OR end_date IS NULL) AND next_date < ?',
        DateTime.now, DateTime.now)
    puts "Checking #{active_recurring.count} recurrences:"
    active_recurring.each do |recurrence|
      type = Object.const_get(recurrence.form_type)
      month_count = (Recurrence.month_count[recurrence.frequency])[:number].months
      puts "Generating #{type.name} for Recurrence ##{recurrence.id}"
      template = type.find(recurrence.template_id)
      next_form = template.clone
      next_form.due_date = template.due_date
      next_form.recurrence_id = recurrence.id
      next_form.template = false;
      if next_form.save!
        recurrence.next_date = recurrence.next_date + month_count
        recurrence.newest_id = next_form.id
        template.due_date = template.due_date + month_count
        if recurrence.save! && template.save!
          puts "New #{type.name} generated: #{type.name} #{next_form.id}: scheduled for due_date on #{next_form.due_date}"
          puts "Next occurence will generate on #{recurrence.next_date} and be scheduled for due_date on #{template.due_date}"
        end
      end
    end
    puts 'FINISH Generating Recurrent Forms:'
  end
end
