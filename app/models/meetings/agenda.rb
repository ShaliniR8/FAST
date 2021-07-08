class Agenda < ActiveRecord::Base

  belongs_to :user, foreign_key: "user_id", class_name: "User"

  def get_content
    "#{user.full_name} #{discussion ? '- Yes' : (discussion.nil? ? "" : '- No')}"
  end


  def preview
    result = []
    result << "<b>Title:</b> #{title}" if title.present?
    result << "<b>Status:</b> #{status}" if status.present?
    result << "<b>User:</b> #{user.full_name}" if user.present?
    result << "<b>Discuss:</b> #{discuss}" if discuss.present?
    if disposition.present?
      if CONFIG.sr::GENERAL[:configurable_agenda_dispositions]
        result << "<b>Dispositions:</b> #{accepted}"
      else
        if accepted == "true"
          result << "<b>Dispositions:</b> Accepted"
        elsif accepted == "false"
          result << "<b>Dispositions:</b> Declined"
        end
      end
    end
    result << "<b>Comment:</b><br> #{comment}" if comment.present?
    result.join('<br>').html_safe
  end


end
