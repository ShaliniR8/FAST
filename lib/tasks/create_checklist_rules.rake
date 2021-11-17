desc 'Creates checklist rules. Notifies and skips for rules already present.'
task :create_checklist_rules => [:environment] do |t|
  begin
    checklist_template_names = Checklist.where(:owner_type => 'ChecklistHeader').map(&:title)
    checklist_template_action_names = AccessControl.get_checklist_template_opts.keys
    checklist_template_action_vals = AccessControl.get_checklist_template_opts.values.flatten

    checklist_template_names.each do |entry|
      puts "Updating Checklist Template #{entry}"
      checklist_template_action_vals.each.with_index do |action, index|
        new_access_hash =  {entry: entry, action: action, list_type: 1, viewer_access: true}
        new_access = AccessControl.new(new_access_hash)
        old_access = AccessControl.where("action = ? AND entry = ?", action, entry)
        if old_access.blank?
          if new_access.save
            puts "  Successfully saved new #{checklist_template_action_names[index]} rule for template #{entry}\n"
          else
            puts "  Failed to save new #{checklist_template_action_names[index]} rule for template #{entry}\n"
          end
        else
          puts "  #{checklist_template_action_names[index]} rule already present for template #{entry}\n"
        end
      end
    end

  rescue => error
    location = "Create Checklist Rules Rake Task"
    subject = "Rake Task Error Encountered In #{location.upcase}"
    error_message = error.message
    NotifyMailer.notify_rake_errors(subject, error_message, location)
  end
end
