class InvitationsController < ApplicationController
  before_filter :login_required
  def update
    @invitation=Invitation.find(params[:id])
    @invitation.status=params[:commit]+"ed"
    @invitation.save
    user=@invitation.user
    host=@invitation.meeting.host.user
    message="#{user.full_name} has #{@invitation.status.downcase} the invitation to meeting ##{@invitation.meeting.get_id}. "+ generate_link_to("Click to view",@invitation.meeting)
    notify(host, message, "Meeting", true)
    respond_to do |format|
      format.html { redirect_to @invitation, notice: 'Done.' }
      format.js   { render :nothing => true }
      format.json { render render: {}.to_json}
    end
  end
end
