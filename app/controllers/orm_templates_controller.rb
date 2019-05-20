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


class OrmTemplatesController < ApplicationController
  before_filter :login_required

  def index
    @title = "ORM Templates"
    @table_name = "orm_templates"
    @headers = OrmTemplate.get_headers
    @records = OrmTemplate.find(:all)
    @new_path = new_orm_template_path
  end

  def new
    @title = "New ORM Template"
    @all_templates = OrmTemplate.find(:all)
    @template = OrmTemplate.new
  end

  def update
    @template = OrmTemplate.find(params[:id])
    if @template.update_attributes(params[:orm_template])
      redirect_to orm_template_path(@template), flash: {success: "ORM Template ##{@template.id} updated."}
    end
  end

  def edit
    @title = "Edit ORM Template"
    @template = OrmTemplate.find(params[:id])
    render :partial => "form"
  end

  def create
    @template = OrmTemplate.new(params[:orm_template])
    @template.created_by = current_user;
    if @template.save
      redirect_to orm_template_path(@template), flash: {success: "ORM Template #{@template.id} created."}
    end
  end

  def show
    @template = OrmTemplate.find(params[:id])
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable }
    @headers = User.get_headers
  end

end
