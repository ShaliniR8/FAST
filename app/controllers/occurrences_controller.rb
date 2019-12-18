class OccurrencesController < ApplicationController

  def create
    #TODO: check if fields are empty- if blank, don't create a new element
  end

  def new
    @templates = OccurrenceTemplate.all
    parent = Object.const_get(params[:owner_type]).find(params[:owner_id])
    root = OccurrenceTemplate.preload(:children).find(1) #TODO: Filter based on parent
    @tree = root.form_tree(@templates)
    render partial: 'new', locals: {
      owner: parent,
      root: root
    }
  end

  def add
    #Despite us calling to post to here, Rails posts all to update from here.
  end

  def show
    #TODO: render partial
  end

  def update
    Occurrence.transaction do
      params[:occurrences].each do |template_id, occurrence|
        next unless occurrence[:value].present?
        Occurrence.create({
          template_id: template_id,
          owner_type: params[:owner_type],
          owner_id: params[:owner_id],
          value: occurrence[:value]
        })
      end
    end
    begin
      parent = Object.const_get(params[:owner_type]).find(params[:owner_id])
      redirect_to parent
    rescue
      redirect_to '/home'
    end
  end

end
