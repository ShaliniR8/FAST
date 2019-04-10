class InvitationsController < ApplicationController
  before_filter :login_required
  def update
  	@invitation=Invitation.find(params[:id])
  	@invitation.status=params[:commit]+"ed"
  	@invitation.save
    user=@invitation.user
    host=@invitation.meeting.host.user
    message="#{user.full_name} has #{@invitation.status.downcase} the invitation to meeting ##{@invitation.meeting.get_id}. "+ generate_link_to("Click to view",@invitation.meeting)
    InvitationMailer.update_invitation(host.email,@invitation)

    #notify(p.user, expire, message, "Meeting", meeting.id, action)
    notify(host, Time.now+2.days, message, "Meeting", @invitation.meeting.id, "action")
    denotify(user, @invitation.meeting, "invite")
    #notify(host,Time.now+2.days,message)
  	respond_to do |format| 
  	  format.html { redirect_to @invitation, notice: 'Done.' }
      format.js   { render :nothing => true }
      format.json { render render: {}.to_json}
  	end
  end
end
