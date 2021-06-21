namespace :recurring do
  desc 'Generate upcoming forms from recurrent items'
  task :generate_recurrent_forms => :environment do
    begin

      puts 'BEGIN Generating Recurrent Forms:'
      active_recurring = Recurrence.where('(end_date > ? OR end_date IS NULL) AND next_date < ?', DateTime.now, DateTime.now)
      puts "Checking #{active_recurring.count} recurrences:"

      active_recurring.each do |recurrence|
        type = Object.const_get(recurrence.form_type)
        frequency = recurrence.frequency
        freq_num = (Recurrence.month_count[recurrence.frequency])[:number]
        recurrence_interval = get_recurrence_interval(frequency, recurrence)
        template = type.find(recurrence.template_id) rescue nil
        if template.present?
          number_of_spawns = recurrence.number_of_recurrencies_per_interval rescue 1
          (1..number_of_spawns).each do |i|
            @next_form = clone_template(template, recurrence)
            if CONFIG.sa::GENERAL[:recurring_item_checklist] 
              @next_form.spawn_id = i
              @next_form.save!  
              attach_checklists_to_audit(recurrence, @next_form)
            end
          end
          recurrence.next_date = recurrence.next_date + recurrence_interval
          recurrence.newest_id = @next_form.id
          template.due_date = template.due_date + recurrence_interval
          if recurrence.save! && template.save!
            puts "New #{type.name} generated: #{type.name} #{@next_form.id}: scheduled for due_date on #{@next_form.due_date}"
            puts "Next occurence will generate on #{recurrence.next_date} and be scheduled for due_date on #{template.due_date}"
          end
        else
          puts "#{type.name} with ID #{recurrence.template_id} not found"
        end
      end
      puts 'FINISH Generating Recurrent Forms:'
    rescue => error
      location = 'recurring:generate_recurrent_forms'
      subject = "Rake Task Error Encountered In #{location.upcase}"
      error_message = error.message
      NotifyMailer.notify_rake_errors(subject, error_message, location)
    end
  end

  def get_recurrence_interval(frequency, recurrence)
    if frequency == 'Daily' || frequency == 'Weekly'
      recurrence_interval = (Recurrence.month_count[recurrence.frequency])[:number].days
      return recurrence_interval
    else
      recurrence_interval = (Recurrence.month_count[recurrence.frequency])[:number].months
      puts(recurrence_interval)
      return recurrence_interval
    end
  end

  def attach_checklists_to_audit(recurrence, next_form)
    associated_checklists = Checklist.where(owner_id: recurrence.template_id) rescue nil
    associated_checklists.each do |id|
      checklist_template = Checklist.preload(checklist_rows: :checklist_cells).find(id)
      Checklist.transaction do
        new_checklist = checklist_template.clone
        next_form.checklists << new_checklist
        checklist_template.checklist_rows.each do |row|
          new_row = row.clone
          new_checklist.checklist_rows << new_row
          row.checklist_cells.each{ |cell| new_row.checklist_cells << cell.clone }
        end
      end
    end
  end

  def clone_template(template, recurrence)
    next_form = template.clone
    next_form.due_date = template.due_date
    next_form.recurrence_id = recurrence.id
    next_form.template = false;
    next_form.save!
    return next_form
  end
end
