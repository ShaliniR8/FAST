class PrivilegesController < ApplicationController

  before_filter :login_required

  def index
    @privileges=Privilege.find(:all)
    @headers=Privilege.get_headers
  end

  def users
    @privilege=Privilege.find(params[:id])
    @headers=User.get_headers
    render :partial => "users"
  end

  def rules
    @privilege=Privilege.find(params[:id])
    @headers=AccessControl.get_headers
    render :partial => "rules"
  end
  def new
    @privilege=Privilege.new
    render :partial => "new"
  end

  def create
    privilege=Privilege.new(params[:privilege])
    if privilege.save
      redirect_to privileges_path
    end
  end

  def destroy
    privilege=Privilege.find(params[:id])
    privilege.destroy
    redirect_to privileges_path
  end


  def edit
    @privilege=Privilege.find(params[:id])
    @headers=AccessControl.get_headers
    @rules = CONFIG::GENERAL[:safety_promotion_visibility].present? ? AccessControl.find(:all) : AccessControl.find(:all).keep_if{|a| ["Safety Promotion", "newsletters", "safety_surveys"].exclude?(a.entry)}
  end

  def update
    privilege=Privilege.find(params[:id])
    privilege.update_attributes(params[:privilege])
    if params[:rules].present?
      privilege.assignments.each do |a|
        if !params[:rules].include? a.access_control.id.to_s
          a.destroy
        end
      end
      params[:rules].each do |r|
        if !privilege.control_ids.include? r.to_i
          assignment=Assignment.new
          assignment.access_controls_id = r
          assignment.privileges_id=params[:id]
          assignment.save
        end
      end
    else
      privilege.assignments.each do |a|
        a.destroy
      end
    end
    privilege.update_user_modified_dates
    redirect_to privileges_path
  end
end
