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


class AutomatedNotificationsController < ApplicationController

	before_filter :login_required

	def new
		@record = AutomatedNotification.new
		@object_types = AutomatedNotification.get_object_types
		render :partial => "form"
	end

	def create
		@record = AutomatedNotification.create(params[:automated_notification])
		redirect_to automated_notifications_path
	end

	def edit
		@record = AutomatedNotification.find(params[:id])

		@object_type = @record.object_type
		@object_class = Object.const_get(@object_type.classify)
		@anchor_date_fields = @object_class.get_meta_fields('form')
			.select{|header| header[:type] == 'date'}
			.map{|x| [x[:title], x[:field]]}.to_h
		@audience_fields = @object_class.get_meta_fields('form')
			.select{|header| header[:type] == 'user'}
			.map{|x| [x[:title], x[:field]]}.to_h
		@anchor_status = @object_class.progress.keys

		render :partial => "form"		
	end

	def update
		@record = AutomatedNotification.find(params[:id])
		@record.update_attributes(params[:automated_notification])
		redirect_to automated_notifications_path
	end

	def destroy
		AutomatedNotification.find(params[:id]).destroy
		redirect_to automated_notifications_path
	end

	def show
	end

	def index
		@title = 'Automated Notifications'
		@table_name = 'automated_notifications'
		@records = AutomatedNotification.all
		@headers = AutomatedNotification.get_meta_fields('index')
		@new_path = new_automated_notification_path
	end

	def retract_fields
		@record = AutomatedNotification.new
		@object_type = params[:object_type]
		@object_class = Object.const_get(@object_type.classify)
		@anchor_date_fields = @object_class.get_meta_fields('form')
			.select{|header| header[:type] == 'date'}
			.map{|x| [x[:title], x[:field]]}.to_h
		@audience_fields = @object_class.get_meta_fields('form')
			.select{|header| header[:type] == 'user'}
			.map{|x| [x[:title], x[:field]]}.to_h
		@anchor_status = @object_class.progress.keys		
		render :partial => "automated_notifications/form_extra"
	end

end