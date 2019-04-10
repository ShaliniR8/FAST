class InvitationMailer < ActionMailer::Base
  include ApplicationHelper
  default :from => "engineering@prosafet.com"

  # #Subject can be set in your I18n file at config/locales/en.yml
  # #with the following lookup:
  
  #   en.invitation_mailer.update_invitation.subject
  
  def update_invitation(email,invitation)
    @invitation=invitation
    @link=generate_link_to("Click to view",invitation.meeting,:use_url=>true).html_safe
    #mail(:to => email,:subject=> "Invitation #{invitation.status}").deliver
  end
end
