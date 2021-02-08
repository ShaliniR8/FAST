desc 'Creates all rules for all modules and all report types. Notifies and skips for rules already present.'
task :create_all_rules => [:environment] do |t|
  begin
    meta = AccessControl.get_meta
    entry_names = AccessControl.entry_options.keys.flatten
    entry_vals = AccessControl.entry_options.values.flatten
    template_names = Template.all.map(&:name)
    template_action_names = AccessControl.get_template_opts.keys
    template_action_vals = AccessControl.get_template_opts.values.flatten

    entry_vals.each.with_index do |entry, index|
      if meta.keys.include?(entry)
        puts "\nUpdating Entry #{entry_names[index]}"
        action_names = meta[entry].keys
        action_vals = meta[entry].values.flatten

        action_vals.each.with_index do |action, index|
          new_access_hash =  {entry: entry, action: action, list_type: 1, viewer_access: false}
          new_access = AccessControl.new(new_access_hash)
          old_access = AccessControl.where("action = ? AND entry = ?", action, entry)
          if old_access.blank?
            if new_access.save
              puts "  Successfully saved new #{action_names[index]} rule for entry #{entry_names[index]}\n"
            else
              puts "  Failed to save new #{action_names[index]} rule for entry #{entry_names[index]}\n"
            end
          else
            puts "  #{action_names[index]} rule already present for entry #{entry_names[index]}\n"
          end
        end
      else
        puts "Entry #{entry_names[index]} does not have any options. Check for possible errors."
      end
    end

    template_names.each do |entry|
      puts "Updating Template #{entry}"
      template_action_vals.each.with_index do |action, index|
        new_access_hash =  {entry: entry, action: action, list_type: 1, viewer_access: true}
        new_access = AccessControl.new(new_access_hash)
        old_access = AccessControl.where("action = ? AND entry = ?", action, entry)
        if old_access.blank?
          if new_access.save
            puts "  Successfully saved new #{template_action_names[index]} rule for template #{entry}\n"
          else
            puts "  Failed to save new #{template_action_names[index]} rule for template #{entry}\n"
          end
        else
          puts "  #{template_action_names[index]} rule already present for template #{entry}\n"
        end
      end
    end

  rescue => error
    location = "Create All Rules Rake Task"
    subject = "Rake Task Error Encountered In #{location.upcase}"
    error_message = error.message
    NotifyMailer.notify_rake_errors(subject, error_message, location)
  end
end
