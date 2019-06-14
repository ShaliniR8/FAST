class OccurrencesController < ApplicationController

  def create
    #TODO: check if fields are empty- if blank, don't create a new element
  end

  def new
    @templates = OccurrenceTemplate.all
    @parent = Object.const_get(params[:owner_type]).find(params[:owner_id])
    root = OccurrenceTemplate.find(1) #TODO: Filter based on parent
    render partial: 'new', locals: {
      # owner_type: params[:owner_type],
      # owner_id: params[:owner_id],
      owner: root
    }
  end

  def new_top
    @templates = OccurrenceTemplate.all
    options = OccurrenceTemplate.where(parent_id: nil) #TODO: Filter based on parent
    render partial: 'form', locals: {
      owner_type: params[:owner_type],
      owner_id: params[:owner_id],
      options: options
    }
  end

  def show
    #TODO: render partial
  end

  def update
    #TODO: check if fields are empty- if blank, delete the element
  end

end
