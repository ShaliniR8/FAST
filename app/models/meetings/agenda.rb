class Agenda < ActiveRecord::Base

  belongs_to :user, foreign_key: "user_id", class_name: "User"

  def get_content
    "#{user.full_name} - #{discussion ? 'Yes' : 'No'}"
  end


  def preview
    result = []
    result << "<b>Title:</b> #{title}" if title.present?
    result << "<b>Status:</b> #{status}" if status.present?
    result << "<b>User:</b> #{user.full_name}" if user.present?
    result << "<b>Discuss:</b> #{discuss}" if discuss.present?
    result << "<b>Dispositions:</b> #{disposition ? 'Accepted' : 'Declined'}" if disposition.present?
    result << "<b>Comment:</b><br> #{comment}" if comment.present?
    result.join('<br>').html_safe
  end


end
