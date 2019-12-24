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


class ExtensionRequestsController < ApplicationController

  before_filter :login_required


  def create
    @extension_request = ExtensionRequest.create(params[:extension_request])
    send_notification(params[:commit], @extension_request)
    redirect_to @extension_request.owner
  end


  def edit
    @extension_request = ExtensionRequest
      .find(params[:id])
      .becomes(ExtensionRequest)
    render :partial => '/extension_requests/new'
  end


  def update
    @extension_request = ExtensionRequest.find(params[:id])
    @extension_request.update_attributes(params[:extension_request])
    @extension_request.owner.update_attribute(:due_date, params[:due_date]) if params[:due_date].present?
    send_notification(params[:commit], @extension_request)
    redirect_to @extension_request.owner
  end


  def address
    @extension_request = ExtensionRequest.find(params[:id]).becomes(ExtensionRequest)
    render :partial => '/extension_requests/address'
  end


  def send_notification(commit, ext_req)
    commit = 'Addresse' if commit == 'Address'
    notify(ext_req.requester,
      "Extension Request has been #{commit}d." + g_link(ext_req.owner),
      true, "Extension Request #{commit}")
  end

end
