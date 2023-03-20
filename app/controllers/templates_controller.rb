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
  require 'yaml'

  def index
    @title = "Safety Reports Templates"
    @headers = Template.get_meta_fields('index')
    @table_name = "templates"
    @table = Object.const_get("Template")
    @records = Template.find(:all)
  end

  def upload_view
    @path = upload_templates_path
    render 'upload_view', layout: false
  end

  def upload
    byebug
    begin
      yaml_attr = YAML.load_file(params["temp_upload"].path)
      Template.transaction do
        begin
          # extract template
          t = Template.extract_template(yaml_attr, current_user)
          @template = t[:template]
          error_msg = t[:error_msg]


          if error_msg == ""
            AccessControl.get_template_opts.map { |disp, db_val|
              AccessControl.new({
                list_type: 1,
                action: db_val,
                entry: @template[:name],
                viewer_access: 1
              }).save
            }
            redirect_to template_path(@template), flash: {success: "Template #{@template.id} created."}
          else
            raise ActiveRecord::Rollback
          end
        rescue
          redirect_to templates_path, flash: {error: error_msg}
          raise ActiveRecord::Rollback
        end
      end
    rescue Psych::SyntaxError => e
        redirect_to templates_path, flash: {error: e.message.split(':')[-1]}
    end
    @action = "upload"
    @eccairs_attributes = EccairsAttribute.all
  end

  def new
    @all_templates = Template.find(:all)
    @template = Template.new
    @action = "new"
    @eccairs_attributes = EccairsAttribute.all
  end


  def clone
    @owner = Template.find(params[:id])
    @template = @owner.make_copy
    redirect_to edit_template_path(@template)
  end


  def edit
    @all_templates = Template.all
    @template = Template.find(params[:id])
    @action = "edit"
    @eccairs_attributes = EccairsAttribute.all
  end


  def create
    @template=Template.new(params[:template])
    @template.created_by=current_user;
    if @template.save
      AccessControl.get_template_opts.map { |disp, db_val|
        AccessControl.new({
          list_type: 1,
          action: db_val,
          entry: @template[:name],
          viewer_access: 1
        }).save
      }
      redirect_to template_path(@template), flash: {success: "Template #{@template.id} created."}
    else
      #TODO: Handle creation error
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
    template_name = template.name
    template.destroy
    AccessControl.where(entry: template_name).map(&:destroy)
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
    updated_name = params[:template][:name]

    if params[:template][:categories_attributes].present?
      params[:template][:categories_attributes].each do |pkey, pcat|
        if !pcat[:deleted].present?
          pcat[:deleted] = false
        end
        if pcat[:fields_attributes].present?
          pcat[:fields_attributes].each do |fkey, pfld|
            if !pfld[:required].present?
              pfld[:required] = false
            end
            if !pfld[:print].present?
              pfld[:print] = false
            end
            if !pfld[:show_label].present?
              pfld[:show_label] = false
            end
          end
        end
      end
    end
    if @template[:name] != updated_name
      AccessControl.where(entry: @template[:name]).update_all(entry: updated_name)
    end
    if @template.update_attributes(params[:template])
      redirect_to template_path(@template), flash: {success: "Template ##{@template.id} updated."}
    end
  end

end
