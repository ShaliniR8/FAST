class AccessControlsController < ApplicationController

  before_filter :login_required, :admin_required



  def index
    @access = CONFIG::GENERAL[:safety_promotion_visibility].present? ? AccessControl.find(:all) : AccessControl.find(:all).keep_if{|a| ["Safety Promotion", "newsletters", "safety_surveys"].exclude?(a.entry)}
    @headers = AccessControl.get_headers
  end



  def module_index
    module_name = params[:module_name]
    @headers = AccessControl.get_headers
    @access = CONFIG::GENERAL[:safety_promotion_visibility].present? ? AccessControl.find(:all) : AccessControl.find(:all).keep_if{|a| ["Safety Promotion", "newsletters", "safety_surveys"].exclude?(a.entry)}
    if module_name != "all"
      rules = AccessControl.module_map[module_name]
      @access = @access.keep_if{|x| rules.include?(x.entry)}
    end
    #byebug
    render :partial => "rule_table"
  end



  def new
    @templates = Template.find(:all)
    @checklist_templates = Checklist.where(owner_type: 'ChecklistHeader')
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
      if Template.all.map(&:name).include?(params[:opt])
        @options = AccessControl.get_template_opts
        @is_temp = "2"
      else
        @options = AccessControl.get_checklist_template_opts
        @is_temp = "3"
      end
    end
    render :partial => 'options'
  end


end
