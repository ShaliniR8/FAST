class NoticesController < ApplicationController

  def new
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @notice = owner.notices.new
    @users = User.where(:disable => 0)
    @headers = User.invite_headers
    @owner_id = params[:owner_id]
    render :partial => '/shared/new_notice', locals: {
      owner_id:   params[:owner_id],
      owner_type: params[:owner_type]
    }
  end

  def create
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @table = params[:owner_type]
    @notice = owner.notices.new(params[:notice])
    @notice.save
    redirect_to "/#{Object.const_get(@table).table_name}/#{params[:notice][:owner_id]}"
  end

  def destroy
    if Notice.find(params[:id]).destroy
      render json: {}, status: 200
    else
      render json: {}, status: 500
    end
  end

end
