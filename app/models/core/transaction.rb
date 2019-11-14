class Transaction < ActiveRecord::Base
  belongs_to :user, foreign_key: 'users_id', class_name: 'User'
  belongs_to :report, foreign_key: 'reports_id', class_name: 'Report'
  belongs_to :owner, polymorphic: true

  PLATFORMS = {
    web:    0,
    mobile: 1,
  }

  def self.build_for(record, action, user_id, content = nil, alt_time = nil, alt_user = nil, platform = nil)
    begin
      record.transactions.create(
        action:     action,
        content:    content,
        users_id:   user_id,
        alt_user:   alt_user.present? ? "#{alt_user.username} - #{alt_user.email}" : '',
        stamp:      alt_time || Time.now,
        platform:   platform || PLATFORMS[:web],
      )
    rescue => e
      Rails.logger.info "Could not save transaction for #{record} with action: \"#{action}\" because #{e}."
    end
  end


  def get_user_name
    if user.present?
      if %w[Submission Record].include? owner_type
        user == owner.created_by ? 'Submitter' : user.full_name
      else
        user.full_name
      end
    elsif alt_user.present?
      "External - #{alt_user}"
    else
      'Anonymous'
    end
  end

end
