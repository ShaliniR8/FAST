class DistributionListsController < ApplicationController

  before_filter :login_required

  def index
    @table = Object.const_get('DistributionList')
    @records = @table.all
    @table_name = 'distribution_lists'
    @title = 'Distribution Lists'
    @headers = @table.get_headers
    @new_path = new_distribution_list_path
  end

  def show
    @record = DistributionList.find(params[:id])
    render json: { :data => { :user_ids => @record.get_user_ids} }
  end

  def new
    @record = DistributionList.new
    @users = User.where('disable = 0 OR disable is null')
    @headers = User.invite_headers
    @distribution_list_users = []
    render :partial => 'form'
  end

  def create
    @record = DistributionList.new(params[:distribution_list])
    if @record.save
      redirect_to distribution_lists_path, flash: {success: "Distribution List ##{@record.id} created."}
    else
      redirect_to distribution_lists_path
    end
    params[:send_to].each do |i,user_id|
      DistributionListConnection.create({
        user_id: user_id,
        distribution_list_id: @record.id
      })
    end
  end

  def edit
    @record = DistributionList.find(params[:id])
    @users = User.where('disable = 0 OR disable is null')
    @headers = User.invite_headers
    @distribution_list_users = @record.distribution_list_connections.map{|con| con.user_id}
    render :partial => 'form'
  end

  def update
    @record = DistributionList.find(params[:id])
    @record.update_attributes(params[:distribution_list])
    @record.distribution_list_connections.each do |connection|
      connection.destroy if params[:send_to].values.exclude?"#{connection.user_id}"
    end
    params[:send_to].each do |i,user_id|
      if @record.distribution_list_connections.where(user_id: user_id).empty?
        DistributionListConnection.create({user_id: user_id, distribution_list_id: @record.id})
      end
    end
    redirect_to distribution_lists_path, flash: {success: "Distribution List ##{@record.id} updated."}
  end

  def destroy
    DistributionList.find(params[:id]).destroy
    redirect_to distribution_lists_path, flash: {danger: "Distribution List ##{params[:id]} deleted."}
  end

end
