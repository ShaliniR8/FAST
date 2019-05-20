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


class VerificationsController < ApplicationController

  before_filter :login_required



  def new
    @table = "#{params[:owner_type]}"
    @owner_id = params[:owner_id]
    @user_id = params[:user_id]
    @verification = Object.const_get(@table).new.becomes(Verification)
    render :partial => '/verifications/new'
  end



  def create
    @table = params[:owner_type]
    @verification = Object.const_get("#{@table}Verification").new(params[:verification])
    @verification.status = "New"
    @verification.save
    redirect_to "/#{Object.const_get(@table).table_name}/#{params[:verification][:owner_id]}"
  end



  def edit
    @verification = Verification
      .find(params[:id])
      .becomes(Verification)
    render :partial => '/verifications/edit'
  end


  def update
    @verification = Verification.find(params[:id])
    @verification.update_attributes(params[:verification])
    Rails.logger.debug "#{@verification.owner.class}"
    redirect_to @verification.owner
  end



  def address
    @verification = Verification.find(params[:id]).becomes(Verification)
    render :partial => '/verifications/address'
  end


end
