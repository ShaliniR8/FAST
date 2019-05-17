class OrmFieldsController < ApplicationController

  def index
  end

  def new
    @field = OrmField.new
  end

  def create
    @field = OrmField.new(params[:orm_field])
    @template = OrmTemplate.find(params[:template_id])
    @field.owner = @template
    if @field.save
      redirect_to orm_template_path(@template), flash: {success: "Field created."}
    else
    end
  end

  def edit
    @field = OrmField.find(params[:id])
  end

  def update
    @field = OrmField.find(params[:id])
    @field.update_attributes(params[:orm_field])
    redirect_to orm_template_path(@field.owner), flash: {success: "Field updated."}
  end

  def destroy
    @field = OrmField.find(params[:id])
    @template = @field.owner
    @field.destroy
    redirect_to orm_template_path(@template), flash: {danger: "Field deleted."}
  end

end
