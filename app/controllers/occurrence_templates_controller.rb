class OccurrenceTemplatesController < ApplicationController

  def create
    @owner = OccurrenceTemplate.new(params[:occurrence_template])
    @owner.save
    redirect_to occurrence_templates_path
  end

  def edit
    @owner = OccurrenceTemplate.find(params[:id])
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
    @records = @table.where(parent_id: nil)
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


end
