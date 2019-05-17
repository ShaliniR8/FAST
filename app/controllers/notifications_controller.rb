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


class NotificationsController < ApplicationController

  before_filter :login_required

  def new
    @users = User.where(:disable => 0)
    @headers = User.invite_headers
    @table = "#{params[:owner_type]}"
    @owner_id = params[:owner_id]
    @notification = Object.const_get(@table).new.becomes(Notification)
    render :partial => '/shared/new_notification'
  end


  def create
    @table = params[:owner_type]
    @notification = Object.const_get("#{@table}Notification").new(params[:notification])
    @notification.save
    redirect_to "/#{Object.const_get(@table).table_name}/#{params[:notification][:owner_id]}"
  end




end
