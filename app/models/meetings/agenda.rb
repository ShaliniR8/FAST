class Agenda < ActiveRecord::Base

  belongs_to :user, foreign_key: "user_id", class_name: "User"

  def get_content
    "#{user.full_name} - #{discussion ? 'Yes' : 'No'}"
  end


  def preview
    title       = ''
    status      = ''
    user        = ''
    discuss     = ''
    disposition = ''
    comment     = ''
    title       = "Title: #{self.title}"                   + '<br>' if self.title.present?
    status      = "Status: #{self.status}"                 + '<br>' if self.status.present?
    user        = "User: #{self.user.full_name}"           + '<br>'
    discuss     = "Discuss: #{self.discuss}"               + '<br>' if self.discuss.present?
    disposition = "Disposition: #{self.disposition}"       + '<br>' if self.disposition.present?
    comment     = 'Comment: ' + '<br>' + "#{self.comment}" + '<br>' if self.comment.present?
    ''.html_safe + title  + status + user + discuss + disposition + comment
  end


end
