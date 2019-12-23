class OccurrenceTemplatesController < ApplicationController
  before_filter :check_admin

  def check_admin
    unless current_user.admin?
      redirect_to gateway_index_path, flash: { danger: 'You do not have access to this action.' }
      return false
    end
  end

  def create
    @owner = OccurrenceTemplate.create(params[:occurrence_template])
    redirect_to occurrence_templates_path
  end

  def edit
    @owner = OccurrenceTemplate.find(params[:id])
    if @owner.id == 1 && @owner.title == 'Default'
      redirect_to occurrence_templates_path,
        flash: { danger: 'You cannot alter the Default Occurrence Template' }
    end
    if @owner.children.blank?
      @formats = OccurrenceTemplate.get_formats.map{ |key, val| [val,key] }
    else
      @formats = [['Section','section']]
    end
    render :partial => 'form', locals: {parent_id: @owner.parent_id}
  end

  def index
    @table = Object.const_get('OccurrenceTemplate')
    @formats = OccurrenceTemplate.get_formats
    @records = @table.where(parent_id: nil, archived: false)
    @fields = @table.get_meta_fields('index')
  end

  def new
    @owner = OccurrenceTemplate.new
    @formats = OccurrenceTemplate.get_formats.map{ |key, val| [val,key] }
    Rails.logger.debug @formats
    render :partial => 'form', locals: {parent_id: params[:parent_id]}
  end

  def update
    @owner = OccurrenceTemplate.find(params[:id])
    @owner.update_attributes(params[:occurrence_template])
    @owner[:options] = '' if !['checkbox','selection'].include? @owner.format
    if @owner.save!
      redirect_to occurrence_templates_path, flash: {success: 'Element updated.'}
    end
  end

  def show
    redirect_to occurrence_templates_path
  end

  def new_root
    @owner = OccurrenceTemplate.create(format: 'section', title: 'New Occurrence Root')
    redirect_to occurrence_templates_path
  end

  def archive
    node = OccurrenceTemplate.find(params[:id])
    if node.id == 1 && node.title == 'Default'
      redirect_to occurrence_templates_path,
        flash: { danger: 'You cannot archive the Default Occurrence Template' }
    else
      node.archive_tree
      redirect_to occurrence_templates_path
    end
  end


end
