class NoticesController < ApplicationController


  def index
    @records = current_user.notices.sort_by(&:created_at).reverse
  end


  def new
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @notice = owner.notices.new
    @users = User.where('disable = 0 OR disable IS NULL')
    @headers = User.invite_headers
    @owner_id = params[:owner_id]
    render :partial => '/shared/new_notice', locals: {
      owner_id:   params[:owner_id],
      owner_type: params[:owner_type]
    }
  end


  def create
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    Rails.logger.debug "Class Name: #{owner.class.name.demodulize}"
    case owner.class.name.demodulize
    when 'Verification'
      owner = owner.owner
    end

    @table = params[:owner_type]
    @notice = owner.notices.new(params[:notice])
    @notice.content = "From #{current_user.full_name}: #{@notice.content} #{g_link(owner)}"
    @notice.save
    redirect_to "/#{Object.const_get(@table).table_name}/#{@notice.owner_id}"
  end


  def destroy
    if Notice.find(params[:id]).destroy
      render json: {}, status: 200
    else
      render json: {}, status: 500
    end
  end


  def read_message
    @owner = Notice.find(params[:id])
    @owner.status = 2
    @owner.save
    redirection = @owner.owner
    if redirection.class.name.demodulize == 'Verification'
      redirection = redirection.owner
    end
    redirect_to redirection || home_index_path
  end


  def mark_all_as_read
    Notice.where(id: params[:notices]).update_all(status: 2)
    render :json => {status: :ok}
  end


end
