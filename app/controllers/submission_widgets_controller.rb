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
    if CONFIG::EXTERNAL_SUBMISSION_TEMPLATE.nil?
      redirect_to root_path
    else
      @template = Template.find(CONFIG::EXTERNAL_SUBMISSION_TEMPLATE)
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
      redirect_to new_submission_widget_path,
      notice: "Your General Safety Report has been submitted."
    else
      redirect_to new_submission_widget_path,
      alert: "Failed"
    end

  end
end
