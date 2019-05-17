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
class TemplatesController < ApplicationController
  # before_filter :login_required
  before_filter :oauth_load # Kaushik Mahorker KM
  def index
    @title = "Safety Reports Templates"
    @headers = Template.get_headers
    @table_name = "templates"
    @records = Template.find(:all)
  end

  def new
    @all_templates=Template.find(:all)
    @template=Template.new
    @action="new"
  end

  def update
    @template=Template.find(params[:id])
    if @template.update_attributes(params[:template])
      redirect_to template_path(@template), flash: {success: "Template ##{@template.id} updated."}
    end
  end

  def edit
    @all_templates=Template.find(:all)
    @template=Template.find(params[:id])
    @action="edit"
  end

  def create
    @template=Template.new(params[:template])
    @template.created_by=current_user;
    if @template.save
      redirect_to template_path(@template), flash: {success: "Template #{@template.id} created."}
    else

    end
  end

  def show
    @template=Template.find(params[:id])
    @users=User.find(:all)
    @users.keep_if{|u| !u.disable }
    @headers=User.get_headers
  end

  def archive
    @template = Template.find(params[:id])
    @template.archive = !@template.archive
    @template.save
    redirect_to template_path(@template)
  end


  def destroy
    template = Template.find(params[:id])
    template.destroy
    redirect_to templates_path
  end



  def show_nested(field_id=nil)
    field_id ||= params[:field_id]
    @field = Field.find(field_id)
    @category = @field.category
    @template = @category.template
    @nested_fields = @field.nested_fields
    respond_to do |format|
      format.js {render "/templates/show_nested_fields", layout: false}
    end
  end

  def edit_nested_fields
    @field = Field.find(params[:field_id])
    @category = Category.find(params[:category_id])
    @category.update_attributes(params[:category])
    show_nested(@field.id)
  end


  def update
    @template=Template.find(params[:id])
    if @template.update_attributes(params[:template])
      redirect_to template_path(@template), flash: {success: "Template ##{@template.id} updated."}
    end
  end


end
