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

class ChecklistRowsController < ApplicationController
  before_filter :define_owner, only: [:new_attachment, :update]

  def new_attachment
    @attachment = Attachment.new
    render partial: 'shared/attachment_modal'
  end

  def update
    @owner.update_attributes(params[:checklist_row])
    @owner.save
    redirect_to audit_path(@owner.checklist.owner)
  end

  def destroy
    ChecklistRow.find(params[:id]).destroy
    render json: {}, status: 200
  end

  private
  def define_owner
    @class = ChecklistRow
    @owner = @class.find(params[:id])
  end

end
