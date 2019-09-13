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

class RootCausesController < ApplicationController


  def new_root_cause(first_id=nil, second_id=nil, i18nbase='core.root_cause')
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @i18nbase = params[:i18nbase] || i18nbase
    @root = CauseOption.where(level: 0, name: "#{params[:owner_type].titleize}").first
    if @root.present?
      @categories = @root.children.keep_if{|x| !x.hidden?}
    end
    respond_to do |format|
      format.js {render "/root_causes/new_root_cause2", layout: false, :locals => {:first_id => first_id, :second_id => second_id, i18nbase: i18nbase} }
    end
  end


  def retract_categories
    second_id = params[:second_id] if params[:second_id]
    @i18nbase = params[:i18nbase]
    @cause_option = CauseOption.find(params[:category])
    @categories = @cause_option.children.keep_if{|x| !x.hidden?}.sort_by{|x| x.name}
    render_category = false
    @categories.each do |x|
      if x.children.length > 0
        render_category = true
      end
    end
    if render_category
      if params[:category_only]
        ancestor_ids = params[:ancestor_ids].present? ? params[:ancestor_ids].split(",").map(&:to_i) : []
        render :partial => "/root_causes/select_category_in_trending", :locals => {:ancestor_ids => ancestor_ids}
      else
        render :partial => "/root_causes/new_root_cause_categories", :locals => {:second_id => second_id}
      end
    else
      if params[:category_only]
        false
      else
        @has_option = @categories.length > 0
        render :partial => "/root_causes/new_root_cause_value"
      end
    end
  end


  def add
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    if params[:root_causes].present?
      if params[:root_causes][:cause_option_id].present?
        root_cause = RootCause.create(
          :owner_id => @owner.id,
          :owner_type => params[:owner_type],
          :user_id  => current_user.id,
          :cause_option_id => params[:root_causes][:cause_option_id],
          :cause_option_value => params[:root_causes][:cause_option_value])
        ancestors = root_cause.cause_option.ancestors
        first_id = ancestors[1].id
        second_id = ancestors[2].id
      end
    end
    first_id ||= nil
    second_id ||= nil
    new_root_cause(first_id, second_id, params[:i18nbase])
  end


  def reload
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @root_cause_headers = RootCause.get_headers
    render :partial => "/root_causes/root_causes_table",
      :locals => {
        :headers => @root_cause_headers,
        :owner => @owner,
        :show_btns => true}
  end


  def destroy
    if RootCause.find(params[:id]).destroy
      render json: {}, status: 200
    else
      render json: {}, status: 500
    end
  end
end
