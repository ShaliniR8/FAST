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


  def create
    @verification = Verification.create(params[:verification])
    redirect_to @verification.owner
  end



  def edit
    @verification = Verification.find(params[:id])
    render :partial => '/verifications/new'
  end


  def update
    @verification = Verification.find(params[:id])
    @verification.update_attributes(params[:verification])
    Rails.logger.debug "#{@verification.owner.class}"
    redirect_to @verification.owner
  end



  def address
    @verification = Verification.find(params[:id])
    render :partial => '/verifications/address'
  end


end
