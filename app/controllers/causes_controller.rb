class CausesController < ApplicationController


  def destroy
    if Cause.find(params[:id]).destroy
      render json: {}, status: 200
    else
      render json: {}, status: 500
    end
  end



  def new_causes
    @owner = Object
      .const_get(params[:owner_type])
      .find(params[:owner_id])

    owner_class_name = @owner.class.superclass.name == "ActiveRecord::Base" ? @owner.class.name : @owner.class.superclass.name

    @categories = Object
      .const_get("#{owner_class_name}#{params[:cause_type].titleize}")
      .categories.keys

    @cause_type = params[:cause_type]
    render :partial => "causes/form"
  end



  def retract_attributes
    @attributes = Object
      .const_get("#{params[:owner_type]}#{params[:cause_type].titleize}")
      .categories[params[:category]]
    render :partial => "causes/attributes"
  end



  def create_causes
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    owner_class_name = @owner.class.superclass.name == "ActiveRecord::Base" ? @owner.class.name : @owner.class.superclass.name
    @object_name = "#{owner_class_name}#{params[:cause_type].titleize}"
    params[:causes].each_pair do |k, v|
      if v.present?
        Object.const_get(@object_name).create(
          :owner_id => @owner.id,
          :category => params[:category],
          :attr => k,
          :value => v)
      end
    end
    redirect_to @owner.becomes(Object.const_get(owner_class_name))
  end



end
