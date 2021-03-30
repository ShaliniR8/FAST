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
    send_notification(params[:commit], @verification)
    redirect_to @verification.owner
  end


  def edit
    @verification = Verification.find(params[:id])
    render :partial => '/verifications/new'
  end


  def update
    @verification = Verification.find(params[:id])
    @verification.update_attributes(params[:verification])
    send_notification(params[:commit], @verification)
    redirect_to @verification.owner
  end


  def address
    @verification = Verification.find(params[:id])
    render :partial => '/verifications/address'
  end


  def destroy
    @verification = Verification.find(params[:id])
    @owner = @verification.owner
    transaction_content = @verification.detail
    @verification.destroy
    Transaction.build_for(
        @owner,
        "Delete Verification",
        current_user.id,
        transaction_content
      )
    redirect_to @verification.owner, flash: {success: 'Verification deleted.'}
  end


  def send_notification(commit, verification)
    commit = 'Addresse' if commit == 'Address'

    verification.get_all_validators.each do |validator|
      notify(verification.owner, notice: {
      users_id: validator.id,
      content: "Verification for #{verification.owner.class.name.titleize} ##{verification.owner.id} has been #{commit}d."},
      mailer: true,
      subject: "Verification #{commit}d") if validator.present?
    end
  end

end
