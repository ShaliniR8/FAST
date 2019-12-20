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

class QueriesController < ApplicationController
  before_filter :login_required
  before_filter :set_table
  before_filter :load_options, :only => [:edit, :new, :index]


  def set_table() @table = Object.const_get("Query") end


  def index
    @headers = @table.get_meta_fields('index')
    @records = @table.where(:target => @types.values)
  end


  def show
    @query_fields = @table.get_meta_fields('show')
    @owner = @table.find(params[:id])
    @chart_types = QueryVisualization.chart_types
    apply_query
  end


  def new
    @owner = Query.new
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
    @logical_types = ['Equals To', 'Not Equal To', 'Contains', 'Does Not Contain', '>=', '<']
    @operators = ["AND", "OR"]
    @owner = params[:query_id].present? ? Query.find(params[:query_id]) : Query.new

    @target = params[:target]
    @templates = Template.where(:id => params[:templates])

    @target_display_name = params[:target_display_name]
    @fields = Object.const_get(@target).get_meta_fields('show', 'index').keep_if{|x| x[:field]}

    if @templates.length > 0
      @templates.map(&:fields).flatten.uniq{|field| field.label}.each{|field|
        @fields << {
          title: field.label,
          field: field.label,
          type: field.data_type,
        }
      }
    end
    @fields = @fields.sort_by{|field| field[:title]}
    render :partial => "building_query"
  end


  # add visualization box to query
  def add_visualization
    @owner = Query.find(params[:id])
    @chart_types = QueryVisualization.chart_types
    @object_type = Object.const_get(@owner.target)
    @fields = @object_type.get_meta_fields('show', 'index').keep_if{|x| x[:field]}
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
    @records = @object_type.where(id: params[:records].split(','))
    # find x_axis field name
    @x_axis_field = get_field(@owner, @object_type, params[:x_axis])
    if params[:series].present? # if series present, build data from both values
      title = "#{params[:x_axis]} By #{params[:series]}"
      # find series field name
      @series_field = get_field(@owner, @object_type, params[:series])
      # build array of hash to stores values for x_axis and series
      arr = create_hash_array(@records, @x_axis_field, @series_field)
      # create a hash to store the occurences of each element
      data_hash = Hash.new
      arr.each do |record|
        x_axis = record[:x_axis].blank? ? 'N/A' : record[:x_axis]
        series = record[:series].blank? ? 'N/A' : record[:series]
        if data_hash[x_axis] && data_hash[x_axis][series]
          data_hash[x_axis][series] += 1
        elsif data_hash[x_axis]
          data_hash[x_axis][series] = 1
        else
          data_hash[x_axis] = Hash.new
          data_hash[x_axis][series] = 1
        end
      end
      # get first row and first column values
      series = data_hash.values.map(&:keys).flatten.uniq
      x_axis = data_hash.keys
      # creates final data array: 2-D array
      row1 = [params[:x_axis]] << series.sort
      @data = [row1.flatten]
      x_axis.sort.each do |x|
        @data << series.inject([x]){|arr, y| arr << (data_hash[x][y] || 0)}
      end
    else # when series not present, use default charts
      @data = [[params[:x_axis], 'Count']]
      @records.map{|record| get_val(record, @x_axis_field)}
        .compact.flatten
        .reject(&:blank?)
        .inject(Hash.new(0)){|h, e| h[e] += 1; h}
        .sort_by{|k,v| k}
        .each{|pair| @data << pair}
      @data.flatten
    end
    @options = { title: title || params[:x_axis] }
    @chart_types = QueryVisualization.chart_types
    render :partial => "/queries/charts/chart_view"
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
    @target_fields = @object_type.get_meta_fields('show', 'index', 'invisible').keep_if{|x| x[:field]}
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
      else
        if @owner.target == "Submission"
          results = emit(condition, records, "Submission")
        elsif @owner.target = "Record"
          results = emit(condition, records, "Record")
        end
      end
    end
    results
  end


  # applies basic condition block
  def emit(condition, records, from_template)
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
            results = emit_helper(condition.value, records, field, false, "equals", from_template)
          else
            results = records.select{|record| (record.send(field[:field]) == "" || record.send(field[:field]) == nil) rescue true}
          end
        when "Not Equal To"
          if field[:type] == 'checkbox'
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
    if from_template == "Submission"
      submission_fields = records.map(&:submission_fields).flatten
      return emit_helper_dynamic(search_value, submission_fields, field, xor, logic_type, "Submission")
    elsif from_template == "Record"
      record_fields = records.map(&:record_fields).flatten
      return emit_helper_dynamic(search_value, record_fields, field, xor, logic_type, "Record")
    else
      return emit_helper_basic(search_value, records, field, xor, logic_type)
    end
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
          matching_users = User.where("full_name = ?", search_value).map(&:id).map(&:to_s) |
            User.where("full_name = ?", search_value).map(&:full_name).map(&:to_s)
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
          matching_users = User.where("full_name LIKE ?", "%#{search_value}%").map(&:id).map(&:to_s) |
            User.where("full_name LIKE ?", "%#{search_value}%").map(&:full_name).map(&:to_s)
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
    elsif target_name == "Record"
      return result.map(&:record)
    else
      return []
    end
  end


  def emit_helper_basic(search_value, records, field, xor, logic_type)
    case logic_type
    when "equals"
      case field[:type]
      when 'boolean_box', 'boolean'
        return records.select{|record| xor ^ ((record.send(field[:field]) ? 'Yes' : 'No').downcase == search_value.downcase)}
      when 'checkbox'
        return records.select{|record| xor ^ (record.send(field[:field]).reject(&:empty?).join("").to_s.downcase == search_value.downcase)}
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
      case field[:type]
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
      case field[:type]
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
    # if top level field
    field = object_type.get_meta_fields('show', 'index', 'invisible')
      .keep_if{|f| f[:title] == field_label}.first
    # else check template fields
    field = Template.preload(:categories, :fields)
      .where(id: query.templates)
      .map(&:fields)
      .flatten
      .select{|x| x.label == field_label}
      .first if field.nil?
    field
  end


  # returns the formatted values of record's field
  def get_val(record, field)
    if field.is_a?(Field)
      field_type = field.display_type
      if record.class == Submission
        value = SubmissionField.where(fields_id: field.id, submissions_id: record.id).first.value rescue nil
      elsif record.class == Record
        value = RecordField.where(fields_id: field.id, records_id: record.id).frist.value rescue nil
      else
        value = 'Something Went Wrong'
      end
    else
      field_type = field[:type]
      value = record.send(field[:field])
    end
    format_val(value, field_type)
  end


  # helper for get_val: formats value based on field type
  def format_val(value, field_type)
    case field_type
    when 'user', 'employee'
      User.find_by_id(value).full_name rescue 'N/A'
    when 'datetime', 'date'
      value.strftime("%Y-%m") rescue 'N/A'
    when 'boolean_box', 'boolean'
      (value ? 'Yes' : 'No') rescue 'No'
    when 'checkbox'
      value.split(';')
    else
      value
    end
  end


  # returns an array that stores x_axis and series value pairs
  def create_hash_array(records, x_axis_field, series_field)
    arr = records.inject([]) do |res, record|
      x_val = get_val(record, x_axis_field)
      y_val = get_val(record, series_field)
      if x_val.is_a?(Array) && y_val.is_a?(Array)
        x_val.each do |x|
          y_val.each do |y|
            res << {x_axis: x, series: y}
          end
        end
      elsif x_val.is_a?(Array)
        x_val.each{|x| res << {x_axis: x, series: y_val}}
      elsif y_val.is_a?(Array)
        y_val.each{|y| res << {x_axis: x_val, series: y}}
      else
        res << {x_axis: x_val, series: y_val}
      end
      res
    end
    arr
  end

end
