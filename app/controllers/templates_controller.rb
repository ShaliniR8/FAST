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

  def upload
    yaml_attr = YAML.load_file(Dir.pwd + "/public/test.yaml")

    @template = Template.new
    fields, nested_fields, categories = Hash.new, Hash.new, []
    Template.transaction do
      begin
        # Handles related templates
        yaml_attr[:Template].each do |key, val| 
          puts key, val
          if key == :related_template
            template = Template.where(name: val)[0]
            val = template.id
            key = :map_template_id
          end
          @template[key] = val 
        end
        @template.save!
        # extract categories
        yaml_attr[:Category].each do |category|
          @category = Category.new 
          category.each do |key, val|
            @category[key] = category[key]
          end

          category_fields = []
          # extract fields in a category
          category[:Field].each do |field|
            @field =  Field.new 
            # TODO: 1. handle incorrect display_type, data_type, etc
            field.each do |key, val|
              unless key == :nested_fields
                @field[key] = field[key]
              end
              # extract nested fields inside current field
              if key == :nested_fields
                field[key].each do |opt_name, field_nested_fields|
                  field_nested_fields.each do |nested_field|
                    @nested_field = Field.new
                    @nested_field.nested_field_value = opt_name
                    nested_field.each do |key_, val_|
                      @nested_field[key_] = val_
                    end
                    (nested_fields[@field.object_id] ||= []) << @nested_field
                  end
                end
              end
            end
            category_fields << @field
          end
          categories << @category
          fields[@category.object_id] = category_fields
        end

        @template.created_by=current_user;
      
        # saving to db
        if @template.save
          template_id = @template.id 
          categories.each do |category|
            category.templates_id = template_id
            if category.save
              categories_id = category.id
              category_fields = fields[category.object_id]
              category_fields.each do |field|
                field.categories_id = categories_id
                field.save
              end
            else
              # Handle error
            end 
          end
          nested_fields.each do |field_obj_id, nested_fields|
            @field = ObjectSpace._id2ref(field_obj_id)
            field_id = @field.id
            categories_id = @field.categories_id
            nested_fields.each do |nested_field|
              nested_field.nested_field_id = field_id
              nested_field.categories_id = categories_id
              nested_field.save
            end
          end
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
          # Handle Error
        end
      rescue
        redirect_to templates_path, flash: {error: "Template creation error."}
        raise ActiveRecord::Rollback
      end
    end
  end

  def new
    @all_templates = Template.find(:all)
    @template = Template.new
    upload
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
