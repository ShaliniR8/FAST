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
    @headers = @table.get_meta_fields('index')
    @records = @table.where(target: @types.values).includes(:created_by)
  end


  def refresh_query
    @owner = @table.find(params[:id])

    query_file_path = "/public/queries/#{params[:id]}.yml"
    query_file_full_path = File.join([Rails.root] + [query_file_path])
    query_processing_file_full_path = query_file_full_path.gsub(/\d+\.yml/) { |d| "processing_#{d}" }

    if File.exist? query_processing_file_full_path
      FileUtils.rm_rf(query_processing_file_full_path)
    elsif File.exist? query_file_full_path
      FileUtils.rm_rf(query_file_full_path)
    end

    redirect_to @owner
  end


  def show
    respond_to do |format|
      format.html do
        @query_fields = @table.get_meta_fields('show')
        @owner = @table.find(params[:id])
        @chart_types = QueryVisualization.chart_types

        if CONFIG::GENERAL[:query_processing_in_rake_task]
          apply_query_with_file
        else
          apply_query
        end

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

        total_records = @records.size

        query_result[:query_detail] = get_query_detail_json(@owner, total_records)
        query_result[:visualizations] = get_visualizations_json(@owner)

        render :json => query_result
      end
    end
  end


  def get_all_query_result_json

    all_queries_result = {}
    @query_fields = @table.get_meta_fields('show')

    Query.all.select { |query| query.is_ready_to_export }.each do |query|

      query_result = {
        query_detail: {},
        visualizations:[]
      }

      @owner = query
      @object_type = Object.const_get(@owner.target)

      @module_name = case @object_type.name
      when 'Submission', 'Record', 'Report', 'CorrectiveAction'
        'ASAP'
      when 'Audit', 'Inspection', 'Evaluation', 'Investigation', 'Finding', 'SmsAction', 'Recommendation'
        'SMS'
      when 'Sra', 'Hazard', 'RiskControl', 'SafetyPlan'
        'SRM'
      end

      records = get_records # get @records
      total_records = records.size

      query_result[:query_detail] = get_query_detail_json(@owner, total_records)
      query_result[:visualizations] = get_visualizations_json(@owner)

      all_queries_result[@owner.id] = query_result
    end

    render :json => all_queries_result
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
    @types["Checklist"] = "Checklist"
  end


  def edit
    @owner = @table.find(params[:id])
  end


  def create
    params[:query][:templates] = params[:query][:templates].split(",")
    @owner = Query.create(params[:query])
    params[:base].each_pair{|index, condition| create_query_condition(condition, @owner.id, nil)} rescue nil
    redirect_to query_path(@owner)
  end


  def update
    @owner = Query.find(params[:id])
    params[:query][:templates] = params[:query][:templates].split(",")
    @owner.update_attributes(params[:query])
    @owner.query_conditions.destroy_all
    params[:base].each_pair{|index, condition| create_query_condition(condition, @owner.id, nil)} rescue nil
    if CONFIG::GENERAL[:query_processing_in_rake_task]
      refresh_query
    else
      redirect_to query_path(@owner)
    end
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
    @logical_types = ['Equals To', 'Not Equal To', 'Contains', 'Does Not Contain', '>=', '<']
    @operators = ["AND", "OR"]
    @owner = params[:query_id].present? ? Query.find(params[:query_id]) : Query.new

    @target = params[:target]
    if @target == 'Report'
      @templates = Template.all
    # elsif @target == 'Checklist'

    else
      @templates = Template.where(:id => params[:templates])
    end

    @target_display_name = params[:target_display_name]

    if @target == 'Checklist'
      @templates = Checklist.where(id: params[:templates])
      @fields = []
      # params[:templates].each do |template_id|
      #   header = Object.const_get(@target).find(template_id.to_i).checklist_header
      #   header.checklist_header_items.each do |header_item|
      #     @fields << {
      #       field: "temp_method",
      #       title: header_item.title,
      #       type: header_item.data_type,
      #       header_id: header_item.id
      #     }
      #   end
      # end
    else
      @fields = Object.const_get(@target).get_meta_fields('show', 'index', 'query', 'invisible').keep_if{|x| x[:field]}
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
    render :partial => "building_query"
  end

  def display_chart_result
    header = 0
    result_all_ids_str = params[:data_ids].gsub("&quot\;", "\'")
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
    @records = @results_ids.map do |result_id|
      @object_type.find(result_id)
    end
  end


  # add visualization box to query
  def add_visualization
    @owner = Query.find(params[:id])
    @chart_types = QueryVisualization.chart_types
    @object_type = Object.const_get(@owner.target)
    @fields = @object_type.get_meta_fields('show', 'index', 'invisible', 'query').keep_if{|x| x[:field]}
    templates = Template.preload(:categories, :fields).where(:id => @owner.templates)
    templates.map(&:fields).flatten.uniq{|field| field.label}.each{|field|
      @fields << {
        title: field.label,
        field: field.label,
        type: field.data_type,
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
      vis.save
    end
    @owner = Query.find(params[:id])
    @object_type = Object.const_get(@owner.target)
    if @object_type == Report
      @records = Report.preload(:records).where(id: params[:records].split(','))
    else
      @records = @object_type.where(id: params[:records].split(','))
    end
    # find x_axis field name
    @x_axis_field = get_field(@owner, @object_type, params[:x_axis])

    if params[:series].present? # if series present, build data from both values
      title = "#{params[:x_axis]} By #{params[:series]}"
      # find series field name
      @series_field = get_field(@owner, @object_type, params[:series])

      @data = get_data_table_for_google_visualization_with_series(x_axis_field_arr: @x_axis_field,
                                                                  series_field_arr: @series_field,
                                                                  records: @records,
                                                                  get_ids: false)

      @data_ids = get_data_table_for_google_visualization_with_series(x_axis_field_arr: @x_axis_field,
                                                                      series_field_arr: @series_field,
                                                                      records: @records,
                                                                      get_ids: true)
    else # when series not present, use default charts
      @data     = get_data_table_for_google_visualization(x_axis_field_arr: @x_axis_field, records: @records)
      @data_ids = get_data_ids_table_for_google_visualization(x_axis_field_arr: @x_axis_field, records: @records)

      # to draw empty charts for empty data
      if @data.length == 1 && @data_ids.length == 1
        @data << ['N/A', 0]
        @data_ids << ['N/A', 0]
      end
    end

    @redirect_page = false

    if params[:nested_xaxis] == true.to_s
      @x_axis_field.first.nested_fields.where(deleted: false).map(&:id).each do |nested_field_id|
        visualization = @owner.visualizations.create(
          x_axis: Field.find(nested_field_id).label
        )
      end
      @redirect_page = true
    end

    if params[:nested_series] == true.to_s
      @series_field.first.nested_fields.where(deleted: false).map(&:id).each do |nested_field_id|
        visualization = @owner.visualizations.create(
          x_axis: Field.find(nested_field_id).label
        )
      end
      @redirect_page = true
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


  def apply_query
    if !session[:mode].present?
      redirect_to choose_module_home_index_path
      return
    end

    adjust_session_to_target(@owner.target) if CONFIG.hierarchy[session[:mode]][:objects].exclude?(@owner.target)
    @title = CONFIG.hierarchy[session[:mode]][:objects][@owner.target][:title].pluralize
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    if ['Record', 'Submission'].include?(@owner.target)
      @headers = filter_submitter_name_header(@headers)
    end
    @target_fields = @object_type.get_meta_fields('show', 'index', 'invisible', 'query').keep_if{|x| x[:field]}
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
        }
      }
    end

    @fields = @target_fields + @template_fields

    if @title == "Submissions"
      records = @object_type.preload(:submission_fields).where(completed: true, templates_id: @owner.templates)
    elsif @title == "Reports"
      records = @object_type.preload(:record_fields).where(:templates_id => @owner.templates)
    else
      records = @object_type.select{|x| ((defined? x.template) && x.template.present?) ? x.template == false : true}
    end

    @owner.query_conditions.each do |condition|
      records = records & expand_emit(condition, records)
    end

    @records = records
  end

  def get_records
    adjust_session_to_target(@owner.target) if CONFIG.hierarchy[@module_name][:objects].exclude?(@owner.target)
    @title = CONFIG.hierarchy[@module_name][:objects][@owner.target][:title].pluralize
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    if ['Record', 'Submission'].include?(@owner.target)
      @headers = filter_submitter_name_header(@headers)
    end
    @target_fields = @object_type.get_meta_fields('show', 'index', 'invisible', 'query').keep_if{|x| x[:field]}
    @template_fields = []
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
      }
    }
    @fields = @target_fields + @template_fields

    if @title == "Submissions"
      records = @object_type.preload(:submission_fields).where(completed: true, templates_id: @owner.templates)
    elsif @title == "Reports"
      records = @object_type.preload(:record_fields).where(:templates_id => @owner.templates)
    else
      records = @object_type.select{|x| ((defined? x.template) && x.template.present?) ? x.template == false : true}
    end
  end


  def apply_query_with_file
    if !session[:mode].present?
      redirect_to choose_module_home_index_path
      return
    end
    adjust_session_to_target(@owner.target) if CONFIG.hierarchy[session[:mode]][:objects].exclude?(@owner.target)
    @title = CONFIG.hierarchy[session[:mode]][:objects][@owner.target][:title].pluralize
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    if ['Record', 'Submission'].include?(@owner.target)
      @headers = filter_submitter_name_header(@headers)
    end

    @target_fields = @object_type.get_meta_fields('show', 'index', 'invisible', 'query').keep_if{|x| x[:field]}
    @template_fields = []
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
      }
    }
    @fields = @target_fields + @template_fields

    query_file_path = "/public/queries/#{params[:id]}.yml"
    query_file_full_path = File.join([Rails.root] + [query_file_path])

    # append 'processing_' to avoid race condition
    # ex. "/public/queries/processing_1234.yml"
    query_processing_file_full_path = query_file_full_path.gsub(/\d+\.yml/) { |d| "processing_#{d}" }

    first_run_query = (not File.exist? query_processing_file_full_path) && (not File.exist? query_file_full_path)

    # 1) RUN QUERY
    if first_run_query
      @records = []
      @status_msg = 'PROCESSING... (Notification will be sent out once the query is ready)'
      @query_status = "new"

      call_rake 'save_query_result',
        title: @title,
        owner_id: @owner.id,
        object_type: @object_type,
        file_path: query_file_full_path,
        user_id: current_user.id,
        processing_file_path: query_processing_file_full_path

    # 2) QUERY PROCESSING..
    elsif File.exist? query_processing_file_full_path
      @records = []
      @status_msg = 'STILL PROCESSING... (Please revisit the page later)'
      @query_status = "new"

    # 3) DISPLAY QUERY RESULT
    elsif File.exist? query_file_full_path
      @records = YAML.load(File.read(query_file_full_path))

      file_updated_at = File.mtime(query_file_full_path)
                          .in_time_zone(CONFIG::GENERAL[:time_zone])
                          .strftime('%a, %d %b %Y %l:%M %p')

      @status_msg = "Last Updated At #{file_updated_at}"
      @query_status = "done"
    end
  end


  def get_records
    adjust_session_to_target(@owner.target) if CONFIG.hierarchy[@module_name][:objects].exclude?(@owner.target)
    @title = CONFIG.hierarchy[@module_name][:objects][@owner.target][:title].pluralize
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    if ['Record', 'Submission'].include?(@owner.target)
      @headers = filter_submitter_name_header(@headers)
    end
    @target_fields = @object_type.get_meta_fields('show', 'index', 'invisible', 'query').keep_if{|x| x[:field]}
    @template_fields = []
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
      }
    }
    @fields = @target_fields + @template_fields

    if @title == "Submissions"
      records = @object_type.preload(:submission_fields).where(completed: true, templates_id: @owner.templates)
    elsif @title == "Reports"
      records = @object_type.preload(:record_fields).where(:templates_id => @owner.templates)
    else
      records = @object_type.select{|x| ((defined? x.template) && x.template.present?) ? x.template == false : true}
    end

    @owner.query_conditions.each do |condition|
      records = records & expand_emit(condition, records)
    end

    @records = records
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
    @templates = Template.where("archive = 0").sort_by{|x| x.name}.map{|template| [template.name, template.id]}.to_h
    @checklists = Checklist.where(owner_type: 'ChecklistHeader').sort_by{|x| x.title}.map{|checklist| [checklist.title, checklist.id]}.to_h
  end


  # applies nested condition blocks
  def expand_emit(condition, records)
    results = []
    if condition.query_conditions.length > 0
      if condition.operator == "AND"
        results = @dynamic_form ? records.map(&:record) : records
        condition.query_conditions.each do |sub_condition|
          results = results & expand_emit(sub_condition, records)
        end
      elsif condition.operator == "OR"
        condition.query_conditions.each do |sub_condition|
          results = results | expand_emit(sub_condition, records)
        end
      end

    else
      if @target_fields.map{|x| x[:title]}.include? condition.field_name
        results = emit(condition, records, false)
      elsif @owner.target == "Checklist"
          results = emit(condition, records,  "Checklist")
      else
        if @owner.target == "Submission"
          results = emit(condition, records, "Submission")
        elsif @owner.target == "Record"
          results = emit(condition, records, "Record")
        elsif @owner.target == "Report"
          events = emit(condition, records, "Report")
          results_ids = events.map(&:id)
          results = []
          records.each do |rec|
            if rec.records.present?
              rec.records.each do |rep|
                if results_ids.include?(rep.id)
                  results << rec
                  break
                end
              end
            end
          end
        end
      end
    end
    results
  end


  # applies basic condition block
  def emit(condition, records, from_template)
    if from_template == "Checklist"
      @field = Checklist.where(owner_type: 'ChecklistHeader').each do |template|
        header = template.checklist_header
        header.checklist_header_items.each do |header_item|
          @fields << {
            field: "temp_method",
            title: header_item.title,
            type: header_item.data_type,
          }
        end
      end
    end

    field = @fields.select{|header| header[:title] == condition.field_name}.first


    if field.present?
      if condition.value.present?
        case condition.logic
        when "Equals To" then results = emit_helper(condition.value, records, field, false, "equals", from_template)
        when "Not Equal To" then results = emit_helper(condition.value, records, field, true, "equals", from_template)
        when "Contains" then results = emit_helper(condition.value, records, field, false, "contains", from_template)
        when "Does Not Contain" then results = emit_helper(condition.value, records, field, true, "contains", from_template)
        when ">=" then results = emit_helper(condition.value, records, field, false, "numeric", from_template)
        when "<" then results = emit_helper(condition.value, records, field, true, "numeric", from_template)
        else results = records
        end
      else
        case condition.logic
        when "Equals To"
          if field[:type] == 'checkbox'
            results = records.select{|record| record.send(field[:field]).reject(&:empty?).join("").to_s == '' || record.send(field[:field]) == nil rescue true}
          elsif field[:field_type] == 'checkbox'
            results = emit_helper(condition.value, records, field, false, "equals", from_template)
          else
            results = records.select{|record| (record.send(field[:field]) == "" || record.send(field[:field]) == nil) rescue true}
          end
        when "Not Equal To"
          if field[:type] == 'checkbox'
            results = records.select{|record| record.send(field[:field] && record.send(field[:field]).reject(&:empty?).join("").to_s != '') != nil rescue true}
          elsif field[:field_type] == 'checkbox'
            results = emit_helper(condition.value, records, field, true, "equals", from_template)
          else
            results = records.select{|record| (record.send(field[:field]) != "" && record.send(field[:field]) != nil) rescue true}
          end
        when "Contains" then results = records
        when "Does Not Contain" then results = []
        else results = []
        end
      end
    end
    return results || []
  end


  def emit_helper(search_value, records, field, xor, logic_type, from_template)
    if from_template == "Checklist"
      return emit_helper_checklist(search_value, records, field, xor, logic_type, "Checklist")
    elsif from_template == "Submission"
      submission_fields = records.map(&:submission_fields).flatten
      return emit_helper_dynamic(search_value, submission_fields, field, xor, logic_type, "Submission")
    elsif from_template == "Record"
      record_fields = records.map(&:record_fields).flatten
      return emit_helper_dynamic(search_value, record_fields, field, xor, logic_type, "Record")
    elsif from_template == "Report"
      record_fields = []
      records.each do |ev|
        if ev.records.present?
          ev.records.each do |rep|
            rep.record_fields.each do |rf|
              record_fields << rf
            end
          end
        end
      end
      return emit_helper_dynamic(search_value, record_fields, field, xor, logic_type, "Report")
    else
      return emit_helper_basic(search_value, records, field, xor, logic_type)
    end
  end


  def emit_helper_checklist(search_value, records, field, xor, logic_type, target_name)
    headers = ChecklistHeaderItem.where(title: field[:title])
    related_cells = ChecklistCell.where(checklist_header_item_id: headers.map(&:id))
    result = []

    case logic_type
    when "equals"
    when "contains"
      records.each do |checklist|
        checklist.checklist_rows.each do |checklist_row|
          checklist_row.checklist_cells.each do |checklist_cell|
            if checklist_cell.value.present? && checklist_cell.value.include?(search_value)
              result << checklist unless result.include? checklist
            end
          end
        end
      end
    when "numeric"
    end

    return result
  end


  def emit_helper_dynamic(search_value, records, field, xor, logic_type, target_name)
    fields = Field.where(:label => field[:title]).map(&:id)
    related_fields = records.select{|x| fields.include? x.fields_id}

    result = []

    case logic_type
    when "equals"
      case field[:data_type]
      when 'datetime', 'date'
        start_date = search_value.split("to")[0]
        end_date = search_value.split("to")[1] || search_value.split("to")[0]
        result = related_fields.select{|x| xor ^ ((x.value.to_date >= start_date.to_date && x.value.to_date <= end_date.to_date) rescue false)}
      else
        case field[:field_type]
        when 'employee'
          if CONFIG::GENERAL[:sabre_integration].present?
            matching_users = User.where("employee_number = ?", "%#{search_value}%").map(&:id).map(&:to_s) |
            User.where("employee_number = ?", search_value).map(&:employee_number).map(&:to_s)
          else
            matching_users = User.where("full_name = ?", search_value).map(&:id).map(&:to_s) |
            User.where("full_name = ?", search_value).map(&:full_name).map(&:to_s)
          end
          result = related_fields.select{|x| xor ^ (matching_users.include? x.value)}
        else
          result = related_fields.select{|x| xor ^ (x.value.to_s.downcase == search_value.to_s.downcase)}
        end
      end

    when "contains"
      case field[:data_type]
      when 'datetime', 'date'
        start_date = search_value.split("to")[0]
        end_date = search_value.split("to")[1] || search_value.split("to")[0]
        result = related_fields.select{|x| xor ^ ((x.value.to_date >= start_date.to_date && x.value.to_date <= end_date.to_date) rescue false)}
      else
        case field[:field_type]
        when 'employee'
          if CONFIG::GENERAL[:sabre_integration].present?
            matching_users = User.where("employee_number LIKE ?", "%#{search_value}%").map(&:id).map(&:to_s) |
            User.where("employee_number LIKE ?", "%#{search_value}%").map(&:employee_number).map(&:to_s)
          else
            matching_users = User.where("full_name LIKE ?", "%#{search_value}%").map(&:id).map(&:to_s) |
            User.where("full_name LIKE ?", "%#{search_value}%").map(&:full_name).map(&:to_s)
          end
          result = related_fields.select{|x| xor ^ (matching_users.include? x.value)}
        else
          result = related_fields.select{|x| xor ^ (x.value.to_s.downcase.include? search_value.to_s.downcase)}
        end
      end

    when "numeric"
      case field[:data_type]
      when 'date', 'datetime'
        dates = search_value.split("to")
        if dates.length > 1
          start_date = dates[0]
          end_date = dates[1]
          result = related_fields.select{|x| xor ^ ((x.value.to_date >= start_date.to_date && x.value.to_date <= end_date.to_date) rescue false)}
        else
          date = dates[0]
          result = related_fields.select{|x| xor ^ ((x.value.to_date >= date.to_date) rescue false)}
        end
      else
        result = related_fields.select{|record| xor ^ ((x.value.to_f >= search_value.to_f) rescue false)}
      end
    end

    if target_name == "Submission"
      return result.map(&:submission)
    elsif target_name == "Record" || target_name == "Report"
      return result.map(&:record)
    else
      return []
    end
  end


  def emit_helper_basic(search_value, records, field, xor, logic_type)
    field_type = field[:type] || field[:field_type]
    case logic_type
    when "equals"
      case field_type
      when 'boolean_box', 'boolean'
        return records.select{|record| xor ^ ((record.send(field[:field]) ? 'Yes' : 'No').downcase == search_value.downcase)}
      when 'checkbox'
        return records.select{ |record|
          if record.send(field[:field]).is_a? Array
            xor ^ (record.send(field[:field]).reject(&:empty?).join("").to_s.downcase.include? search_value.downcase)
          else
            xor ^ (record.send(field[:field]).split("\;").reject(&:empty?).join("").to_s.downcase.include? search_value.downcase)
          end
        }
      when 'user'
        if search_value.downcase == "Anonymous".downcase
          return records.select{|record| xor ^ (record.send(field[:field]).to_s.downcase == search_value.downcase)}
        else
          matching_users = User.where("full_name = ?", search_value).map(&:id)
          return records.select{|record| xor ^ (matching_users.include? record.send(field[:field]))}
        end
      when 'date', 'datetime'
        start_date = search_value.split("to")[0]
        end_date = search_value.split("to")[1] || search_value.split("to")[0]
        return records.select{|x| xor ^ ((x.send(field[:field]).to_date >= start_date.to_date && x.send(field[:field]).to_date <= end_date.to_date) rescue false)}
      else
        return records.select{|record| xor ^ (record.send(field[:field]).to_s.downcase == search_value.to_s.downcase)}
      end
    when "contains"
      case field_type
      when 'boolean_box', 'boolean'
        return records.select{|record| xor ^ ((record.send(field[:field]) ? 'Yes' : 'No').downcase == search_value.downcase)}
      when 'user'
        matching_users = User.where("full_name LIKE ?", "%#{search_value}%").map(&:id)
        return records.select{|record| xor ^ (matching_users.include? record.send(field[:field]))}
      when 'date', 'datetime'
        start_date = search_value.split("to")[0]
        end_date = search_value.split("to")[1] || search_value.split("to")[0]
        return records.select{|x| xor ^ ((x.send(field[:field]).to_date >= start_date.to_date && x.send(field[:field]).to_date <= end_date.to_date) rescue false)}
      else
        return records.select{|record| xor ^ ((record.send(field[:field]).to_s.downcase.include? search_value.downcase) rescue false)}
      end
    when "numeric"
      case field_type
      when 'date', 'datetime'
        dates = search_value.split("to")
        if dates.length > 1
          start_date = dates[0]
          end_date = dates[1]
          return records.select{|x| xor ^ ((x.send(field[:field]).to_date >= start_date.to_date && x.send(field[:field]).to_date <= end_date.to_date) rescue false)}
        else
          date = dates[0]
          return records.select{|x| xor ^ ((x.send(field[:field]).to_date >= date.to_date) rescue false)}
        end
      else
        return records.select{|record| xor ^ ((record.send(field[:field]).to_f >= search_value.to_f) rescue false)}
      end
    end
    return []
  end


  # builds query conditions
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
    label = field_label.split(',').map(&:strip)[0]
    # if top level field
    field = object_type.get_meta_fields('show', 'index', 'invisible', 'query')
      .keep_if{|f| f[:title] == label}.first
    # else check template fields
    field = Template.preload(:categories, :fields)
      .where(id: query.templates)
      .map(&:fields)
      .flatten
      .select{|x| x.label == label}
      .first if field.nil?
    [field, field_label.split(',').map(&:strip)[1]]
  end

end
