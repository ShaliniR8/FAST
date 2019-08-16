class ActivityTracker < ActiveRecord::Base
  has_one :user, :foreign_key => "user_id", :class_name => "User"
end
=begin
Create activity_tracker upon login
Set user id = current user
Set last_active = created_at
Update activity_tracker.last_active every time filter occurs
For the most recent activity_tracker where user_id = current user and created_at = current date

at end of the day 
add up each user from that day's total hours to find total
=end
