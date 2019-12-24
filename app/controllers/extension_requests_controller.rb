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
    send_notification('New', @extension_request)
    redirect_to @extension_request.owner
  end



  def edit
    @extension_request = ExtensionRequest
      .find(params[:id])
      .becomes(ExtensionRequest)
    render :partial => '/extension_requests/edit'
  end



  def update
    @extension_request = ExtensionRequest.find(params[:id])
    @extension_request.update_attributes(params[:extension_request])
    send_notification('Address', @extension_request)
    redirect_to @extension_request.owner
  end



  def address
    @extension_request = ExtensionRequest.find(params[:id]).becomes(ExtensionRequest)
    render :partial => '/extension_requests/address'
  end



  def send_notification(status, ext_req)
    case status
    when 'New'
      notify(ext_req.requester,
        "A new Extension Request has been submitted." + g_link(ext_req.owner),
        true, 'Extension Request submitted')
    else
      notify(ext_req.approver,
        "Your Extension Request has been addressed." + g_link(ext_req.owner),
        true, 'Extension Request addressed')
    end
  end

end
