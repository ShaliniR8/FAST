class OccurrencesController < ApplicationController

  def new
    @templates = OccurrenceTemplate.all
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    root = OccurrenceTemplate.preload(:children).find_by_title(owner.class.name.titleize)
    root ||= OccurrenceTemplate.preload(:children).find(1) # This has to be the default node
    @tree = root.form_tree(@templates)
    render partial: 'new', locals: {
      owner: owner,
      root: root
    }
  end

  def destroy
    occurrence = Occurrence.find(params[:id])
    if current_user.has_access(class_to_table(@owner.class), 'edit', admin: true)
      if occurrence.destroy
        render json: {}, status: 200
      else
        render json: {}, status: 500
      end
    else
      flash[:danger] = "You do not have permission to alter this #{occurrence.owner_type.titleize}"
    end
  end


  def add
    #Despite us calling POST to here, Rails posts all to update from here.
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
