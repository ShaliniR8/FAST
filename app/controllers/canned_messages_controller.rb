class CannedMessagesController < ApplicationController

	def index
		@table = Object.const_get("CannedMessage")
		@records = @table.all
		@table_name = "canned_messages"
		@title = "Message Templates"
		@headers = @table.get_headers
		@new_path = new_canned_message_path
	end

	def show
		@record = CannedMessage.find(params[:id])
		render json: { :data => { :content => @record.content} }
	end

	def new
		@record = CannedMessage.new
		render :partial => "form"
	end

	def create
		@record = CannedMessage.new(params[:canned_message])
		if @record.save
			redirect_to canned_messages_path, flash: {success: "Canned Message ##{@record.id} created."}
		else
			flash[:error] = @record.errors.full_messages.first
			redirect_to canned_messages_path
		end
	end

	def edit
		@record = CannedMessage.find(params[:id])
		render :partial => "form"
	end

	def update
		@record = CannedMessage.find(params[:id])
		@record.update_attributes(params[:canned_message])
		redirect_to canned_messages_path, flash: {success: "Canned Message ##{@record.id} updated."}
	end

	def destroy
		CannedMessage.find(params[:id]).destroy
    redirect_to canned_messages_path, flash: {danger: "Template ##{params[:id]} deleted."}
	end

end