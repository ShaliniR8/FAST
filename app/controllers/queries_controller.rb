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

require 'yaml'

class QueriesController < ApplicationController
  include QueriesHelper

  before_filter :login_required
  before_filter :set_table
  before_filter :load_options, :only => [:edit, :new, :index]


  def set_table() @table = Object.const_get("Query") end


  def index
    has_access = current_user.has_access('home', 'query_all', admin: CONFIG::GENERAL[:global_admin_default])
    redirect_to errors_path unless has_access

    @headers = @table.get_meta_fields('index')
    handle_search
  end


  def show
    respond_to do |format|
      format.html do
        @query_fields = @table.get_meta_fields('show')
        @owner = @table.find(params[:id])
        @chart_types = QueryVisualization.chart_types

        apply_query

        if defined?(params[:eccairs]) && params[:eccairs]
          call_rake "eccairs:export", email: current_user.email, records: JSON.dump(@records.map(&:id))
          redirect_to "/queries/#{@owner.id}"
        end

      end
      format.json do
        query_result = {
          query_detail: {},
          visualizations:[]
        }

        @query_fields = @table.get_meta_fields('show')
        @owner = Query.find(params[:id])
        @object_type = Object.const_get(@owner.target)
        apply_query

        total_records = @records_ids.size

        query_result[:query_detail] = get_query_detail_json(@owner, total_records)
        query_result[:visualizations] = get_visualizations_json(@owner)

        render :json => query_result
      end
    end
  end


  def enable
    query = Query.find(params[:id])
    query.is_ready_to_export = !query.is_ready_to_export
    query.save

    msg = query.is_ready_to_export ? 'Enabled to Export' : 'Disabled to Export'

    render json: {
      message: msg,
    }
  end


  def new
    @owner = Query.new
  end


  def edit
    @owner = @table.find(params[:id])
  end


  def create
    params[:query][:templates] = "" if ['Record', 'Report', 'Submission', 'Checklist'].exclude?(params[:query][:target])
    params[:query][:templates] = params[:query][:templates].split(",")
    @owner = Query.create(params[:query])
    unless params["distribution_list_ids"] == "" || (params["threshold"]) == ""
      @owner.set_threshold({:distros => params["distribution_list_ids"], :threshold => params["threshold"]})
    end
    params[:base].each_pair{|index, condition| create_query_condition(condition, @owner.id, nil)} rescue nil
    redirect_to query_path(@owner)
  end


  def update
    @owner = Query.find(params[:id])
    if params[:commit] != 'Save Subscription List'
      params[:query][:templates] = "" if ['Record', 'Report', 'Submission', 'Checklist'].exclude?(params[:query][:target])
      params[:query][:templates] = params[:query][:templates].split(",")
      @owner.update_attributes(params[:query])
      @owner.query_conditions.destroy_all
      params[:base].each_pair{|index, condition| create_query_condition(condition, @owner.id, nil)} rescue nil
    else
      @owner.update_attributes(params[:query])
    end
    unless params["distribution_list_ids"] == "" || (params["threshold"]) == ""
      @owner.set_threshold({:distros => params["distribution_list_ids"], :threshold => params["threshold"]})
    end
    redirect_to query_path(@owner)
  end


  def clone
    @owner = Query.find(params[:id])
    @query = @owner.make_copy
    redirect_to edit_query_path(@query)
  end


  def destroy
    @owner = Query.find(params[:id])
    @owner.destroy
    redirect_to queries_path, flash: {danger: "Query deleted."}
  end


  # on target select, load conditions block - primarily used to show only relevant fields
  def load_conditions_block
    @logical_types = ['Equals To', 'Not Equal To', 'Contains', 'Does Not Contain', '>=', '<', 'Last ( ) Days']
    @operators = ["AND", "OR"]
    @owner = params[:query_id].present? ? Query.find(params[:query_id]) : Query.new
    @target = params[:target]
    if @target == 'Report'
      @templates = Template.all
    elsif @target == 'Checklist'
      @templates =  Checklist.where(id: params[:templates])
      @no_template_option = params[:templates].include?('-1') rescue false
    else
      @templates = Template.where(:id => params[:templates])
    end

    @target_display_name = params[:target_display_name]

    if @target == 'Checklist' && params[:templates].present?
      @templates = Checklist.where(id: params[:templates])
      @fields = []
      params[:templates].each do |template_id|
        if template_id == '-1'
          ChecklistHeader.all.each do |header|
            header.checklist_header_items.each do |header_item|
              @fields << {
                field: "temp_method",
                title: header_item.title.strip(),
                type: header_item.data_type,
                header_name: header.title
              }
            end
          end
        else
          header = Object.const_get(@target).find(template_id.to_i).checklist_header
          header.checklist_header_items.each do |header_item|
            @fields << {
              field: "temp_method",
              title: header_item.title.strip(),
              type: header_item.data_type,
              header_name: header.title
            }
          end
          @fields = @fields.uniq
        end
      end


      # Combine the same header column name
      @fields = @fields.group_by { |field| field[:title] }.map { |val| val[1] }.map do |fields|
        header_name = fields.map {|field| field[:header_name] }.join(', ')
        {
          field: fields.first[:field],
          title: fields.first[:title],
          type: fields.first[:type],
          header_name: header_name
        }
      end


      # @fields = @fields.uniq
    else
      @fields = Object.const_get(@target).get_meta_fields('show', 'index', 'query', 'invisible', 'close').keep_if{|x| x[:field]}
    end

    if @templates.length > 0 && @target != 'Checklist'
      @templates.map(&:fields).flatten.uniq{|field| field.label}.each{|field|
        @fields << {
          title: field.label,
          field: field.label,
          type: field.data_type,
        }
      }
    end
    @fields = @fields.sort_by{|field| (field[:title].present? ? field[:title] : "")}
    @distribution_list = DistributionList.all.map{|d| [d.id, d.title]}.to_h
    render :partial => "building_query"
  end


  def print
    @owner = @table.find(params[:id])
    html = render_to_string(template: 'queries/print.html.slim')
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Query ##{@owner.id}"
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def display_chart_result
    header = 0
    result_all_ids_str = params[:data_ids].gsub("&quot\;", "\'")
    result_all_ids_str.gsub!("[\'[", "[[")
    result_all_ids_str.gsub!("]\'", "]")

    result_all_ids = ActiveSupport::JSON.decode(result_all_ids_str)
    params[:row] = params[:row].to_i + 1 if result_all_ids[1][0].to_s.empty? # first row is for empty records

    if result_all_ids[header][1] == 'IDs' # when series not present
      @results_ids = result_all_ids[params[:row].to_i][1]
    else
      @results_ids = result_all_ids[params[:row].to_i][params[:col].to_i]
    end

    x_axis_value = result_all_ids[params[:row].to_i][0]
    serise_value = result_all_ids[header][params[:col].to_i] unless result_all_ids[header][1] == 'IDs'

    @title = serise_value.present? ? "#{x_axis_value} & #{serise_value}" : x_axis_value

    @owner = Query.find(params[:id])
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    if ['Record', 'Submission'].include?(@owner.target)
      @headers = filter_submitter_name_header(@headers)
    end
    if ['Record', 'Submission', 'Report'].include?(@owner.target)
      @headers = filter_event_title_header(@headers)
    end
    @records = @results_ids.map do |result_id|
      @object_type.find(result_id)
    end
  end


  # add visualization box to query
  def add_visualization
    @owner = Query.find(params[:id])
    @chart_types = QueryVisualization.chart_types
    @object_type = Object.const_get(@owner.target)
    @fields = @object_type.get_meta_fields('show', 'index', 'invisible', 'query', 'close').keep_if{|x| x[:field]}
    templates = Template.preload(:categories, :fields).where(:id => @owner.templates)
    templates.map(&:fields).flatten.uniq{|field| field.label}.each{|field|
      @fields << {
        title: field.label,
        field: field.label,
        type: field.data_type,
        nested_field_title: field.nested_field_value
      }
    }
    visualization = @owner.visualizations.create
    render :partial => 'visualization', :locals => {
      records: params[:records],
      visualization: visualization}
  end


  # remove visualization box to query
  def remove_visualization
    QueryVisualization.find(params[:visualization_id]).destroy
    render :json => true
  end

  # generate indivisual visualization blocks
  def generate_visualization
    @visualization = QueryVisualization.find(params[:visualization_id]).tap do |vis|
      vis.x_axis = params[:x_axis]
      vis.series = params[:series]
      vis.default_chart = params[:default_chart]
      if params["series"].present?
        vis.set_threshold(nil)
      end
      if params["threshold"].present?
        vis.set_threshold(params["threshold"])
      end
      vis.save
    end
    @owner = Query.find(params[:id])
    @object_type = Object.const_get(@owner.target)

    # find x_axis field name
    @x_axis_field = get_field(@owner, @object_type, params[:x_axis])
    # find series field name
    @series_field = get_field(@owner, @object_type, params[:series])

    if params[:series].present? && params[:x_axis].present? # if series present, build data from both values
      title = "#{params[:x_axis]} By #{params[:series]}"
      @data = get_data_table_for_google_visualization_with_series(x_axis_field_name: params[:x_axis],
                                                                  x_axis_field_arr: @x_axis_field,
                                                                  series_field_arr: @series_field,
                                                                  records_ids: params[:records].split(','),
                                                                  get_ids: false,
                                                                  query: @owner)

      @data_ids = get_data_table_for_google_visualization_with_series(x_axis_field_name: params[:x_axis],
                                                                      x_axis_field_arr: @x_axis_field,
                                                                      series_field_arr: @series_field,
                                                                      records_ids: params[:records].split(','),
                                                                      get_ids: true,
                                                                      query: @owner)

    elsif params[:x_axis].present?
      @data     = get_data_table_for_google_visualization_sql(x_axis_field_arr: @x_axis_field, records_ids: params[:records].split(','), query: @owner)
      @data_ids = get_data_ids_table_for_google_visualization_sql(x_axis_field_arr: @x_axis_field, records_ids: params[:records].split(','), query: @owner)

      # to draw empty charts for empty data
      if @data.length == 1 && @data_ids.length == 1
        @data << ['N/A', 0]
        @data_ids << ['N/A', 0]
      end

    elsif params[:series].present?
      title     = "#{params[:series]}"
      @data     = get_data_table_for_google_visualization_sql(x_axis_field_arr: @series_field, records_ids: params[:records].split(','), query: @owner)
      @data_ids = get_data_ids_table_for_google_visualization_sql(x_axis_field_arr: @series_field, records_ids: params[:records].split(','), query: @owner)

      # to draw empty charts for empty data
      if @data.length == 1 && @data_ids.length == 1
        @data << ['N/A', 0]
        @data_ids << ['N/A', 0]
      end

    end

    @data = @data.map{ |x| [x[0].to_s, x[1..-1]].flatten}
    @data_ids = @data_ids.map{ |x| [x[0].to_s, x[1..-1]].flatten(1)}

    # REMOVE unnecessary quotes
    @data_ids = @data_ids.map{ |x| [x[0].gsub('"', '').gsub("\'", ''), x[1..-1]].flatten(1)}

    @redirect_page = false

    if params[:nested_xaxis] == true.to_s && @x_axis_field.first.is_a?(Field)
      @x_axis_field.first.nested_fields.where(deleted: false).map(&:id).each do |nested_field_id|
        visualization = @owner.visualizations.create(
          x_axis: Field.find(nested_field_id).label
        )
        @redirect_page = true
      end
    end

    if params[:nested_series] == true.to_s && @series_field.first.is_a?(Field)
      @series_field.first.nested_fields.where(deleted: false).map(&:id).each do |nested_field_id|
        visualization = @owner.visualizations.create(
          x_axis: Field.find(nested_field_id).label
        )
        @redirect_page = true
      end
    end

    @options = { title: title || params[:x_axis] }
    @chart_types = QueryVisualization.chart_types
    render :partial => "/queries/charts/chart_view"
  end


  def filter_submitter_name_header(headers)
    if !CONFIG.sr::GENERAL[:show_submitter_name]
      if !current_user.global_admin?
        headers.delete_if {|x| x[:field] == 'get_submitter_name'}
      end
    else
      if !current_user.admin?
        headers.delete_if {|x| x[:field] == 'get_submitter_name'}
      end
    end
    headers
  end

  def filter_event_title_header(headers)
    if !CONFIG.sr::GENERAL[:show_event_title_in_query]
      if !current_user.global_admin?
        headers.delete_if {|x| x[:field] == 'description'}
      end
    else
      if !current_user.admin?
        headers.delete_if {|x| x[:field] == 'description'}
      end
    end
    headers
  end


  def apply_query
    if !session[:mode].present?
      redirect_to choose_module_home_index_path
      return
    end

    adjust_session_to_target(@owner.target) if CONFIG.hierarchy[session[:mode]][:objects].exclude?(@owner.target)
    @title = CONFIG.hierarchy[session[:mode]][:objects][@owner.target][:title].pluralize
    @object_name = @owner.target
    @object_type = Object.const_get(@object_name)
    @table_name = @object_type.table_name
    @object = CONFIG.hierarchy[session[:mode]][:objects][@object_name]

    @columns = get_data_table_columns(@object_name)
    @columns.delete_if {|x| x[:data] == 'get_additional_info_html'}

    if ['Record', 'Submission'].include?(@owner.target)
      if !CONFIG.sr::GENERAL[:show_submitter_name]
        if !current_user.global_admin?
          @columns.delete_if {|x| x[:data] == 'get_submitter_name'}
        end
      else
        if !current_user.admin?
          @columns.delete_if {|x| x[:data] == 'get_submitter_name'}
        end
      end
    end

    if ['Record', 'Submission', 'Report'].include?(@owner.target)
      if !CONFIG.sr::GENERAL[:show_event_title_in_query]
        if !current_user.global_admin?
          @columns.delete_if {|x| x[:data] == 'description'}
        end
      else
        if !current_user.admin?
          @columns.delete_if {|x| x[:data] == 'description'}
        end
      end
    end

    if @object_name == 'Sra' && !CONFIG.srm::GENERAL[:risk_assess_sras].present?
      @columns.delete_if {|x| ["get_risk_classification", "get_risk_classification_after"].include?(x[:data])}
    end

    @column_titles = @columns.map { |col| col[:title] }
    @date_type_column_indices = @column_titles.map.with_index { |val, inx|
      (val.downcase.include?('date') || val.downcase.include?('time')) ? inx : nil
    }.select(&:present?)

    @source_column_indices = @column_titles.map.with_index { |val, inx|
      (val.downcase.include?('source of input')) ? inx : nil
    }.select(&:present?)


    @target_fields = @object_type.get_meta_fields('show', 'index', 'invisible', 'query', 'close').keep_if{|x| x[:field]}
    @template_fields = []

    if @owner.target == "Checklist"
      # @owner.templates
    else
      Template.preload(:categories, :fields)
        .where(id:  @owner.templates)
        .map(&:fields)
        .flatten
        .uniq{|field| field.label}
        .each{|field|
        @template_fields << {
          title: field.label,
          field: field.label,
          data_type: field.data_type,
          field_type: field.display_type,
          nested_field_title: field.nested_field_value
        }
      }
    end

    @fields = @target_fields + @template_fields
    @records_ids = get_query_results_ids(@owner)
    @target = @owner.target
    @is_query_ready = true
  end


  def add_subscribers_view
    @owner = Query.find(params[:id])
    render :partial => 'shared/subscriptions'
  end


  def retrieve_pin_fields
    @visualization = QueryVisualization.find(params[:visualization_id])
    @chart_types = QueryVisualization.chart_types
    render :partial => '/queries/retrieve_pin_fields'
  end


  def pin_visualization
    @visualization = QueryVisualization.find(params[:visualization_id])
    query = Query.find(@visualization.owner_id)

    @visualization.dashboard_pin = true
    @visualization.dashboard_pin_size = params[:dashboard_chart_size].to_i
    @visualization.dashboard_default_chart = params[:default_dashboard_chart].to_i
    @visualization.save

    visualization_file_path = "/public/query_vis/#{@visualization.id}.yml"
    visualization_file_full_path = File.join([Rails.root] + [visualization_file_path])
    visualization_processing_file_full_path = visualization_file_full_path.gsub(/\d+\.yml/) { |d| "processing_#{d}" }
    @visualization.delay.compute_visualization(current_user.id, @visualization.query.id, visualization_file_full_path,
                                               visualization_processing_file_full_path, get_query_results_ids(query).split(','), query)

    redirect_to query_path(@visualization.query), flash: {success: "Visualization recomputing for dashboard view."}
  end


  def unpin_visualization
    @data = nil
    @status_msg = ""
    @visualization = QueryVisualization.find(params[:visualization_id])

    @visualization.dashboard_pin = false
    @visualization.save

    visualization_file_path = "/public/query_vis/#{@visualization.id}.yml"
    visualization_file_full_path = File.join([Rails.root] + [visualization_file_path])
    visualization_processing_file_full_path = visualization_file_full_path.gsub(/\d+\.yml/) { |d| "processing_#{d}" }

    if File.exist? visualization_processing_file_full_path
      FileUtils.rm_rf(visualization_processing_file_full_path)
    end

    if File.exist? visualization_file_full_path
      FileUtils.rm_rf(visualization_file_full_path)
    end

    render json: {vis_id: @visualization.id, message: "Visualization has been Un-Pinned from the Dashboard"}
  end


  private

  # Set session[:mode] to match the mode of the target query
  def adjust_session_to_target(target)

    # Set a list of potential query targets
    @sms_list = ['Audit','Inspection','Evaluation','Investigation','Finding','SmsAction']
    @sms_im_list = ['Im'] # unused
    @asap_list = ['Submission','Report','Record','CorrectiveAction']
    @srm_list = ['Sra','Hazard','RiskControl','SafetyPlan']

    case target
    when *@sms_list
      session[:mode] = 'SMS'
    when *@sms_im_list
      session[:mode] = 'SMS IM'
    when *@asap_list
      session[:mode] = 'ASAP'
    when *@srm_list
      session[:mode] = 'SRM'
    end
  end


  def load_options
    if !session[:mode].present?
      redirect_to choose_module_home_index_path
      return
    end
    @types = CONFIG.hierarchy[session[:mode]][:objects].map{|key, value| [key, value[:title]]}.to_h.invert
    @types.delete("Checklist") unless CONFIG::GENERAL[:checklist_query]
    @templates = Template.where("archive = 0").sort_by{|x| x.name}.map{|template| [template.name, template.id]}.to_h
    @checklists = Checklist.includes(:checklist_header).where(owner_type: 'ChecklistHeader').sort_by{|x| x.title}.map{|checklist| ["#{checklist.title} [#{checklist.checklist_header.title}]", checklist.id]}.to_h
  end


  # # builds query conditions
  def create_query_condition(condition_hash, query_id, query_condition_id)
    if condition_hash['operator'].present?
      parent = QueryCondition.create({
        :operator => condition_hash['operator'],
        :query_id => query_id,
        :query_condition_id => query_condition_id})
      condition_hash.each_with_index do |(hash_id, condition), index|
        if index > 0
          create_query_condition(condition, nil, parent.id)
        end
      end
    elsif condition_hash["logic"].present? || condition_hash["field"].present? || condition_hash["value"]
      condition = QueryCondition.create({
        :logic => condition_hash["logic"],
        :field_name => condition_hash["field"],
        :value => condition_hash["value"],
        :query_id => query_id,
        :query_condition_id => query_condition_id})
    end
  end


  # returns the field that matches field_label
  def get_field(query, object_type, field_label)
    # label = field_label.split(',').map(&:strip)[0]
    label = field_label

    # if top level field
    field = object_type.get_meta_fields('show', 'index', 'invisible', 'query', 'close')
      .keep_if{|f| f[:title] == label}.first
    # else check template fields
    field = Template.preload(:categories, :fields)
      .where(id: query.templates)
      .map(&:fields)
      .flatten
      .select{|x| x.label.strip == label.strip}
      .first if field.nil?
    # [field, field_label.split(',').map(&:strip)[1]]
    [field, field_label]
  end

end
