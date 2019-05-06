class Transaction < ActiveRecord::Base
  belongs_to :user, foreign_key: "users_id",class_name:"User"
  belongs_to :report, foreign_key: "reports_id",class_name:"Report"
  belongs_to :owner, polymorphic: true

  def self.build_for(record, action, user_id, content=nil, alt_time=nil)
    begin
      record.transactions.create(
        action:     action,
        content:    content,
        users_id:   (user_id),
        stamp:      (alt_time || Time.now)
      )
    rescue
      Rails.logger.info "Could not save transaction for #{record} with action: \"#{action}\"."
    end
  end

end
