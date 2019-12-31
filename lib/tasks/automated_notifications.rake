namespace :notifications do

  desc "Send automated notifications/reminders."
  task :automated_notifications => :environment do

    all_rules = AutomatedNotification.all

    all_rules.each do |rule|
      object_type = rule.object_type
      anchor_date_field = rule.anchor_date_field
      audience_field = rule.audience_field
      anchor_status = rule.anchor_status
      interval = rule.interval
      subject = rule.subject
      content = rule.content

      records = Object.const_get(object_type.classify)
        .where("status = ? AND #{anchor_date_field} = ?",
          anchor_status, Time.now.in_time_zone.to_date + interval.days)
      puts "Alert ##{rule.id} count: #{records.length}"
      records.each do |record|
        user = User.find(record.send(audience_field)) rescue nil
        if user.present?
          NotifyMailer.automated_reminder(user, subject, content, record)
          record.notices.create({users_id: user.id, content: content})
        end
      end
    end
  end

  desc 'Send out user-designated email reminders'
  task :send_reminders => :environment do

    Notice.where('create_email = TRUE AND
      (expire_date > ? OR expire_date IS NULL) AND
      (start_date < ? OR start_date IS NULL)',
      DateTime.now,
      DateTime.now
    ).include(:user).each do |notice|
      NotifyMailer.notify(notice.user, notice.content, 'ProSafeT User Notice')
      notice.create_email = false
      puts "Email sent to #{notice.user.full_name} for Notice ##{notice.id}" if notice.save!
    end
  end

end

