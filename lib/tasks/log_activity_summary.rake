namespace :log do
  task :summary => :environment do
    track_airline_log = BaseConfig.airline[:track_log]
    if track_airline_log
      trackers = ActivityTracker.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now.end_of_day)
      if trackers.present?
        date_time = DateTime.now.in_time_zone('Pacific Time (US & Canada)')
        file_date = date_time.strftime("%Y%m%d")
        file_name = "#{Rails.root}/log/tracker_" << file_date << ".log"
        tracking_log = Logger.new(file_name)
        active_user_ids = trackers.map{|t| t.user_id}.uniq!
        total_activity_time_in_seconds = 0
        active_user_ids.each do |id|
          user_activities = ActivityTracker.where :user_id => id
          activity_time_in_seconds = 0
          user_activities.each do |a|
            activity_time_in_seconds += ((a.last_active - a.created_at)/3600).round(2)
          end
          tracking_log.info("***#{User.find(id).full_name} Activity Summary: #{activity_time_in_seconds} hours***")
          total_activity_time_in_seconds += activity_time_in_seconds
        end
        tracking_log.info("===Total Daily Activity: #{total_activity_time_in_seconds.round(2)} hours===")
      end
    end
  end
end
