# Current version of Ruby (2.1.1p76) and Rails (3.0.5) defines send s.t. saving nested attributes does not work
# This method is a "monkey patch" that can fix the issue (tested for Rails 3.0.x)
# Source: https://github.com/rails/rails/issues/11026
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
class OrmSubmissionsController < ApplicationController

  before_filter :login_required

  def index
    @title = "ORM Submissions"
    @table_name = "orm_submissions"
    @records = OrmSubmission.find(:all)
    @headers = OrmSubmission.get_headers
  end

  def new
    @has_template = false
    if !params[:template].blank?
      @has_template = true
      @template = OrmTemplate.find(params[:template])
      @record = OrmSubmission.build(@template)
      @record.orm_submission_fields.build
    else
      @templates = OrmTemplate.find(:all)
      @templates.sort_by!{|x| x.name}
    end
  end

  def create
    @record = OrmSubmission.new(params[:orm_submission])
    @record.save
    redirect_to orm_submission_path(@record)
  end

  def show
    @record = OrmSubmission.find(params[:id])
    @fields = @record.orm_submission_fields
    @template = @record.orm_template
  end

  def destroy
    @record = OrmSubmission.find(params[:id])
    @record.destroy
    redirect_to orm_submissions_path
  end


end
