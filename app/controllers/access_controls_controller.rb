class AccessControlsController < ApplicationController

  before_filter :login_required, :admin_required



  def index
    @access = AccessControl.find(:all)
    @headers = AccessControl.get_headers
  end



  def module_index
    module_name = params[:module_name]
    @headers = AccessControl.get_headers
    @access = AccessControl.find(:all)
    if module_name != "all"
      rules = AccessControl.module_map[module_name]
      @access = @access.keep_if{|x| rules.include?(x.entry)}
    end
    render :partial => "rule_table"
  end



  def new
    @templates = Template.find(:all)
    @new_access = AccessControl.new
    @entry_options = AccessControl.entry_options
    @action_options = AccessControl.action_options
    @list_options = AccessControl.list_type_options
    render :partial => 'form'
  end



  def create
    if params[:access_control][:entry].blank? ||
      params[:access_control][:action].blank?
      redirect_to access_controls_path
    end
    @access = AccessControl.new(params[:access_control])
    test = AccessControl.where("action = ? AND entry = ?",
      @access.action,
      @access.entry)
    if test.blank?
      if @access.save
        redirect_to access_controls_path
      end
    end
  end



  def destroy
    rule = AccessControl.find(params[:id])
    rule.assignments.each{|x| x.destroy}
    rule.destroy
    redirect_to access_controls_path
  end



  def list_privileges
    access = AccessControl.find(params[:id])
    @privileges = access.privileges
    @headers = Privilege.get_headers
    render :partial => 'listing'
  end



  def get_options
    meta = AccessControl.get_meta
    if meta.keys.include? params[:opt]
      @options = meta[params[:opt]]
      @is_temp = "1"
    else
      @options = AccessControl.get_template_opts
      @is_temp = "2"
    end
    render :partial => 'options'
  end


end
