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

class SubmissionWidgetsController < ApplicationController
  skip_before_filter :new, :create

  def new
    @template = Template.find(params[:template_id])

    if @template.nil?
      redirect_to root_path
    else
      @record = Submission.build(@template)
      @record.submission_fields.build
      @action = "new"
      render layout: false
    end
  end


  def create
    params[:submission][:submission_fields_attributes].each_value do |field|
      if field[:value].is_a?(Array)
        field[:value].delete("")
        field[:value] = field[:value].join(";")
      end
    end

    @record = Submission.new(params[:submission])

    if @record.save
      @record.make_report
      notify_notifiers(@record)
      redirect_to new_submission_widget_path + "/#{params[:submission][:templates_id]}",
      notice: "Your General Safety Report has been submitted."
    else
      redirect_to new_submission_widget_path + "/#{params[:submission][:templates_id]}",
      alert: "Failed"
    end

  end


  def notify_notifiers(owner)
    mailer_privileges = AccessControl.where(
      :action => 'notifier',
      :entry => owner.template.name)
      .map{|x| x.privileges.map(&:id)}.flatten

    notifiers = User.preload(:privileges)
      .where("disable is null or disable = 0")
      .keep_if{|x| x.privileges.map(&:id) & mailer_privileges != []}

    call_rake 'submission_notify',
            owner_type: owner.class.name,
            owner_id: owner.id,
            users: notifiers.map(&:id),
            attach_pdf: CONFIG.sr::GENERAL[:attach_pdf_submission]
  end
end
