class CustomOptionsController < ApplicationController


  def index
    @table = Object.const_get("CustomOption")
    @records = @table.all
    @table_name = "custom_options"
    @title = "Custom Options"
    @headers = @table.get_headers
    @new_path = new_custom_option_path
  end

  def new
    @record = CustomOption.new
    render :partial => "form"
  end

  def create
    @record = CustomOption.new(params[:custom_option])
    if @record.save
      redirect_to custom_options_path, flash: {success: "Custom Option for #{@record.title} created"}
    else
      flash[:error] = @record.errors.full_messages.first
      redirect_to custom_options_path
    end
  end

  def show
    @record = CustomOption.find(params[:id])
    render json: { :data => { :title => @record.title, :options => @record.options }}
  end

  def edit
    @record = CustomOption.find(params[:id])
    render :partial => "form"
  end

  def update
    @record = CustomOption.find(params[:id])
    @record.update_attributes(params[:custom_option])
    redirect_to custom_options_path, flash: {success: "#{@record.title} updated." }
  end


  def destroy
    CustomOption.find(params[:id]).destroy
    redirect_to custom_options_path, flash: {danger: "Custom Option deleted."}
  end

end
