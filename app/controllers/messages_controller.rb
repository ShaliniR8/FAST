class MessagesController < ApplicationController



  def new
    if params[:reply_to].present?
      @reply_to = Message.find(params[:reply_to])
    end
    @send_to = params[:send_to].present? ? params[:send_to].to_i : -1
    Rails.logger.debug @send_to.to_s
    @message = Message.new()
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable}
    @headers = User.invite_headers
  end


  def destroy
    @message=Message.find(params[:id])
    if params[:source]=="Sent"
      s=@message.send_from
      s.visible=false
      s.save
    else
      @message.send_to.each do |s|
        if s.user==current_user
          s.visible=false
          s.save
        end
      end
      @message.cc.each do |s|
        if s.user==current_user
          s.visible=false
          s.save
        end
      end
    end
  end



  def create
    @message = Message.new(params[:message])
    @message.time = Time.now
    @message.save
    ma = SendFrom.new(:messages_id => @message.id, :users_id => current_user.id)
    ma.save
    if params[:send_to].present?
      params[:send_to].values.each do |v|
        ma = SendTo.new(:messages_id => @message.id, :users_id => v)
        notify(User.find(v),
          "You have a new internal message. " + g_link(@message),
          true, 'New Internal Message')
        ma.save
      end
    end
    if params[:cc_to].present?
      params[:cc_to].values.each do |v|
        ma = CC.new(:messages_id => @message.id, :users_id => v)
        notify(User.find(v),
          "You have a new internal message. " + g_link(@message),
          true, 'New Internal Message')
        ma.save
      end
    end
    if params[:reply_to].present?
      @reply_to = Message.find(params[:reply_to])
      @message.response = @reply_to
      @message.save
      @send_to = SendTo.where("messages_id = ? and users_id = ?", @reply_to.id, current_user.id).first
      if @send_to.present?
        @send_to.status = "Replied"
      end
    end
    redirect_to message_path(@message), flash: {success: "Message sent."}
  end



  def show
    @message = Message.find(params[:id])
    @report_link = @message.link
    if current_user.has_access_to @message
      need_reply=@message.send_to.map{|x| x.user}.include? current_user
    else
      redirect_to root_url
    end
  end



  def sent
    @messages = current_user.sent_messages.select{|x| x.visible}.map{|x| x.message}
    @title = "Sent"
  end



  def index
    @title="Inbox"
    @messages=current_user.inbox_messages.select{|x| x.visible}.map{|x| x.message}+current_user.cc_messages.select{|x| x.visible}.map{|x| x.message}
    @messages.uniq!{|x| x.id}
  end



  def prev
    @message=Message.find(params[:id])
    @dialogs=@message.getPrev.delete_if{|x| x.id==@message.id}
    Rails.logger.debug @dialogs.inspect
    render :partial =>"dialogs"
  end



  def reply
    @message=Message.find(params[:id])
    @dialogs=@message.getDialogs.delete_if{|x| x.id==@message.id}
    Rails.logger.debug @dialogs.inspect
    render :partial =>"dialogs"
  end



  def foward
  end



  def mark_as_read(user,message)
    messages=MessageAccess.where("users_id=? AND messages_id=?",user.id,message.id)
    messages.each do |m|
      if m.type!="SendFrom"
        m.status="Read"
        m.save
      end
    end
  end



  def inbox
    @title = params[:source]
    @message = Message.find(params[:id])
    @report_link = get_message_link(@message.link_type, @message.link_id)
    mark_as_read(current_user,@message)
    render :partial => 'inbox'
  end


end
