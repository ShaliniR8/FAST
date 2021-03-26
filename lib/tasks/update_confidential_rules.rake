desc 'Update rules with confidential access for all templates if confidential forms are configured'
task :update_confidential_rules => [:environment] do |t|
  begin
    if CONFIG::GENERAL[:has_confidential_forms].present?
      templates = Template.find(:all)
      action = 'confidential'

      templates.each do |temp|
        puts "Updating Template #{temp.name}"
        new_access_hash =  {entry: temp.name, action: action, list_type: 1, viewer_access: true}
        new_access = AccessControl.new(new_access_hash)
        old_access = AccessControl.where("action = ? AND entry = ?", action, temp.name)
        if old_access.blank?
          if new_access.save
            puts "  Successfully saved new #{action} rule for template #{temp.name}\n"
          else
            puts "  Failed to save new #{action} rule for template #{temp.name}\n"
          end
        else
          puts "  #{action} rule already present for template #{temp.name}\n"
        end
      end
    end
  rescue => error
    location = "Update Rules Rake Task"
    subject = "Rake Task Error Encountered In #{location.upcase}"
    error_message = error.message
    NotifyMailer.notify_rake_errors(subject, error_message, location)
  end
end
