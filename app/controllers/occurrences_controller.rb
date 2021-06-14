class OccurrencesController < ApplicationController

  def new
    @templates = OccurrenceTemplate.where(archived: false)
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])

    # find the top-level occurrence template's section
    root = owner.class.find_top_level_section

    @tree = root.form_tree(@templates)
    @label = root.label

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
      (params[:occurrences] || []).each do |template_id, occurrence|
        next unless occurrence[:value].present?
        Occurrence.create({
          template_id: template_id,
          owner_type: params[:owner_type],
          owner_id: params[:owner_id],
          value: occurrence[:value].strip
        })

        if params[:owner_type] == 'Submission'
          Occurrence.create({
            template_id: template_id,
            owner_type: 'Record',
            owner_id: Submission.find(params[:owner_id]).records_id,
            value: occurrence[:value].strip
          })
        end
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
