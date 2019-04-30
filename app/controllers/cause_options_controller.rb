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



class CauseOptionsController < ApplicationController



  def index
    @table = Object.const_get("CauseOption")
    @records = @table.where(:level => 0)
    @table_name = "cause_options"
    @title = "Root Causes"
    @headers = @table.get_headers
  end



  def show
    @record = CauseOption.find(params[:id])
  end



  def new
    @parent = CauseOption.find(params[:parent_id])
    @root = CauseOption.find(params[:root_id])
    @option = CauseOption.new
    @level = @parent.level + 1
    render :partial => "form"
  end



  def create
    @root_option = CauseOption.find(params[:root_id])
    @parent_option = CauseOption.find(params[:parent_id])
    @option = CauseOption.new(params[:cause_option])
    @option.save
    @parent_option.cause_options << @option
    @option.cause_options << @parent_option
    redirect_to cause_option_path(@root_option)
  end



  def edit
    @option = CauseOption.find(params[:id])
    @parent = @option.parent
    @level = @option.level
    @root = @option.root
  end



  def update
    @option = CauseOption.find(params[:id])
    if @option.update_attributes(params[:cause_option])
      redirect_to cause_option_path(@option.root), flash: {success: "Label updated."}
    end
  end



  def download
    @record = CauseOption.find(params[:id])
    filename = "RootHazards##{@record.id}"
    respond_to do |format|
      format.xls{
        name = "attachment; filename=" + filename + ".xls"
        response.headers["Content-Disposition"] = name
        render "download_excel.xls.erb", :layout => false
      }
    end
  end



  def destroy
    option = CauseOption.find(params[:id])
    @root = option.root
    delete_helper(option)
    redirect_to cause_option_path(@root)
  end

  # Comment lines back to delete the options completely
  def delete_helper(option)
    #parent = option.parent
    #parent.cause_options.delete(option)
    #option.cause_options.delete(parent)
    option.hidden = true
    option.save
    if option.children.present?
      option.children.each do |x|
        delete_helper(x)
      end
    end
    #option.destroy
  end



end
