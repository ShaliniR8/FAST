# Current version of Ruby (2.1.1p76) and Rails (3.0.5) defines send s.t. saving nested attributes does not work
# This method is a "monkey patch" that can fix the issue (tested for Rails 3.0.x)
# Source: https://github.com/rails/rails/issues/11026
if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
  module ActiveRecord
    module Associations
      class AssociationProxy
        def send(method, *args)
          if proxy_respond_to?(method, true)
            super
          else
            load_target
            @target.send(method, *args)
          end
        end
      end
    end
  end
end


class MessagesController < ApplicationController
  before_filter :oauth_load

  include Concerns::Mobile

  def new
    @message = Message.new
    @users = User.where('disable = 0 OR disable is null')
    @headers = User.invite_headers
    if params[:reply_to].present?
      @reply_to = Message.find(params[:reply_to])
      @owner = @reply_to.owner
    end
    @owner ||= Object.const_get(params[:owner_class]).find(params[:owner_id]) rescue nil
    if @owner.class.name == "VpIm"
      @owner = @owner.becomes(Im)
    end
    @send_to = params[:send_to].present? ? params[:send_to].to_i : -1
  end


  def message_submitter
    @message = Message.new
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @send_to = @owner.created_by.id
    render :partial => 'message_submitter'
  end


  def create
    external = ""
    if params[:message][:external].present?
      external = params[:message][:external]
      params[:message].delete('external')
    else
      params[:message].delete('external')
    end

    @message = Message.new(params[:message])
    @message.time = Time.now
    @message.save
    SendFrom.create(
      messages_id: @message.id,
      users_id: current_user.id,
      anonymous: (params[:from_anonymous] || false))

    if external.present?
      send_external_emails(external, params[:message])
    end

    if params[:reply_to].present?
      @reply_to = Message.find(params[:reply_to])
      if @reply_to.send_from.anonymous
        params[:send_to] = { 0 => @reply_to.send_from.user.id }
        params[:to_anonymous] = true
      end
      @message.response = @reply_to
      @message.save
      @send_to = SendTo.where('messages_id = ? and users_id = ?', @reply_to.id, current_user.id).first
      if @send_to.present?
        @send_to.status = 'Replied'
      end
    end

    no_of_attachments = params[:message][:attachments_attributes].present? ? params[:message][:attachments_attributes].size : 0

    # send messages
    pattern = /(\'|\"|\.|\*|\/|\-|\\|\)|\$|\+|\(|\^|\?|\!|\~|\`)/
    subject_line = params[:message][:subject].gsub(pattern){|match| ""}

    call_rake 'notify',
      messages_id: @message.id,
      owner_type: params[:message][:owner_type],
      owner_id: params[:message][:owner_id],
      subject: subject_line,
      send_to: params[:send_to],
      cc_to: params[:cc_to],
      to_anonymous: params[:to_anonymous],
      attach_pdf: (params[:attach_pdf] || false),
      extra_attachments: no_of_attachments

    if @message.owner
      Transaction.build_for(
        @message.owner,
        params[:commit],
        (params[:from_anonymous].present? && params[:from_anonymous].to_i == 1) ? nil : (session[:simulated_id] || session[:user_id]),
        g_link(@message)
      )
    end

    respond_to do |format|
      redirect_object = @message.owner
      if @message.owner.present? && @message.owner.class.name == 'VpIm'
        redirect_object = @message.owner.becomes(Im)
      end
      format.json {render json: {message: 'Message sent.'}}
      format.html {redirect_to redirect_object || message_path(@message), flash: { success: 'Message Sent' }}
    end

  end


  def send_external_emails(externals, message)
    if message[:owner_type] == 'Record' || message[:owner_type] == 'Submission'
      table = Object.const_get(message[:owner_type])
      emails = externals.split(',').map{|email| email.strip}
      NotifyMailer.send_external(current_user, emails, message[:subject], message[:content], table.find(message[:owner_id]))
    end
  end


  def destroy
    @message = Message.find(params[:id])
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


  def show
    @message = Message.find(params[:id])
    if current_user.has_access_to(@message)
      need_reply=@message.send_to.map{|x| x.user}.include? current_user
    else
      redirect_to root_url, flash: { notice: 'You do not have permission to view that message.' }
    end
  end


  def sent
    @messages = current_user.sent_messages.select{|x| x.visible && x.message.present?}.map{|x| x.message}.uniq.sort_by {|m| m.time.present? ? m.time : ""}.reverse
    @title = "Sent"
  end


  def index
    @title = 'Inbox'
    @messages = [current_user.inbox_messages, current_user.cc_messages].map{ |message_accesses|
      message_accesses.includes(message: [
        :owner,
        send_from: :user,
        send_to: :user,
        cc: :user
      ]).select(&:visible).map(&:message)
    }.flatten.compact
    # @messages.uniq!
    @messages = @messages.uniq.sort_by {|m| m.time.present? ? m.time : ""}.reverse

    respond_to do |format|
      format.html
      format.json { index_as_json }
    end
  end


  def prev
    @message = Message.find(params[:id])
    @dialogs = @message.getPrev.delete_if{|x| x.id == @message.id}
    render :partial =>"dialogs"
  end


  def reply
    @message = Message.find(params[:id])
    @dialogs = @message.getDialogs.delete_if{|x| x.id == @message.id}
    render :partial =>"dialogs"
  end

  def mark_as_read(user_id, message_id)
    messages = MessageAccess.where(users_id: user_id, messages_id: message_id)
    messages.each do |m|
      if m.type != 'SendFrom'
        m.status = 'Read'
        m.save
      end
    end
  end


  def inbox
    @title = params[:source]
    @message = Message.find(params[:id])
    @report_link = get_message_link(@message.owner_type, @message.owner_id)
    mark_as_read(current_user.id, @message.id)
    render :partial => 'inbox'
  end


  def delete_multiple
    message_ids_to_delete = params[:message_ids].split(',')

    if params[:source] == "Sent"
      SendFrom.where(messages_id: message_ids_to_delete).map{|s| s.update_attributes({visible: false})}
    else
      SendTo.where(messages_id: message_ids_to_delete).map{|s| s.update_attributes({visible: false, status: 'Read'})}
      CC.where(messages_id: message_ids_to_delete).map{|s| s.update_attributes({visible: false, status: 'Read'})}
    end

    render json: { message: "#{message_ids_to_delete.count} #{message_ids_to_delete.count > 1 ? 'Messages' : 'Message'} deleted" }
  end


end
