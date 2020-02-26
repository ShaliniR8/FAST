class InvitationsController < ApplicationController

  before_filter :login_required


  def update
    @invitation = Invitation.find(params[:id])
    @invitation.status = params[:commit] + "ed"
    @invitation.save
    user = @invitation.user
    host = @invitation.meeting.host.user
    notify(@invitation.meeting, notice: {
      users_id: host.id,
      content: "#{user.full_name} has #{@invitation.status.downcase} the invitation to meeting ##{@invitation.meeting.get_id}."},
      mailer: true, subject: "Meeting #{@invitation.status.downcase}")
    respond_to do |format|
      format.html { redirect_to @invitation, notice: 'Done.' }
      format.js   { render :nothing => true }
      format.json { render render: {}.to_json}
    end
  end

end
