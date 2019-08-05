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

  before_filter :set_table
  before_filter :load_options, :only => [:edit, :new, :index]

  def set_table() @table = Object.const_get("Query") end

  def index
    @headers = @table.get_meta_fields('index')
    @records = @table.where(:target => @types.values)
  end

  def show
    @query_fields = @table.get_meta_fields('show', 'index')
    @owner = @table.find(params[:id])
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
    @fields.sort_by{|field| field[:title]}
    render :partial => "building_query"
  end



  # add visualization box to query
  def add_visualization
    @owner = Query.find(params[:id])
    @object_type = Object.const_get(@owner.target)
    @fields = @object_type.get_meta_fields('show', 'index').keep_if{|x| x[:field]}

    templates = Template.where(:id => @owner.templates)
    templates.map(&:fields).flatten.uniq{|field| field.label}.each{|field|
      @fields << {
        title: field.label,
        field: field.label,
        type: field.data_type,
      }
    }

    @owner.visualizations ||= []
    @owner.visualizations << Time.now.strftime("%Y%m%d%H%M%S")
    @owner.save
    render :partial => "visualization", :locals => {
      records: params[:records],
      field_id: @owner.visualizations.last.parameterize,
      field_name: ""}
  end

  # remove visualization box to query
  def remove_visualization
    @owner = Query.find(params[:id])
    @owner.visualizations.delete(params["field_name"])
    @owner.save
    render :json => true
  end


  # generate visualization charts
  def generate_visualization

    # determines if empty value should be take into account
    show_empty_value = false

    @owner = Query.find(params[:id])
    @label = params[:field_name]
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')

    records = params[:records].split(",") || []
    @result = @object_type.where(:id => records)


    @target_fields = @object_type.get_meta_fields('show', 'index').keep_if{|x| x[:title] == @label}

    @template_fields = []
    Template.preload(:fields).where(:id => @owner.templates).map(&:fields).flatten.select{|x| x.label == @label}.each{|field|
      @template_fields << field
    }
    @fields = @target_fields + @template_fields

    dynamic_field = (@target_fields.map{|x| x[:title]}.include? @label) == false

    visualization_index = @owner.visualizations.index(params["field_id"].titleize) ||
      @owner.visualizations.index(params["field_name"])

    @owner.visualizations[visualization_index] = @label
    @owner.save

    if dynamic_field
      @field = @fields.first

      if @field.data_type == "datetime" || @field.data_type == "date"
        field_type = @field.data_type
      elsif @field.display_type == "checkbox"
        field_type = @field.display_type
      else
        field_type = 'text'
      end

      @field = {
        :title => @field.label,
        :field => @field.label,
        :type => field_type,
        :options => @field.getOptions
      }

    else
      @field = @object_type.get_meta_fields('show', 'index')
        .select{|header| (header[:title] == @label && header[:field].present?)}.first
      field_type = @field[:type]
    end

    result_id = []
    @result.each{ |r| result_id << r.id }

    # Create Hash to store value and occurance
    @data = Hash.new

    # Create Hash for each checkbox options
    if field_type == "checkbox"
      if dynamic_field
        @fields.each do |f|
          hash = Hash.new
          hash = Hash[f.getOptions.collect { |item| [item, 0] } ]
          @data = @data.merge(hash)
        end
      else
        temp_hash = Hash.new
        temp_hash = Hash[@field[:options].collect{|item| [item.gsub("'",""), 0]}]
        @data = @data.merge(temp_hash)
      end

    elsif field_type == "boolean_box"
      @data["Yes"] = 0
      @data["No"] = 0

    # Create key value pair for unique values
    else
      if dynamic_field
        if @owner.target == "Submission"
          @data = Hash[SubmissionField.where(:fields_id => @fields.collect{|x| x.id}, :submissions_id => result_id)
            .select(:value).map(&:value).uniq.collect{|item| [item, 0]}]
        elsif @owner.target == "Record"
          @data = Hash[RecordField.where(:fields_id => @fields.collect{|x| x.id}, :records_id => result_id)
            .select(:value).map(&:value).uniq.collect{|item| [item, 0]}]
        end
      else
        @data = Hash[
          @result.map{|x| x.send(@field[:field])}
            .compact.uniq.collect{|item| [(item.gsub("\r\n", " ").gsub("'", "") rescue item), 0]}
        ]
      end
    end
    @data["*No Input"] = 0 if show_empty_value

    # Iterate through result to update Hash
    @result.each do |r|
      value = dynamic_field ? r.get_field_by_label(@label) : r.send(@field[:field])
      value = value.present? ? value : (show_empty_value ? "*No Input" : nil)
      if field_type == 'checkbox'
        if value.present?
          value = dynamic_field ? value.split(";") : value
          value.each do |v|
            if @data[v].present?
              @data[v] += 1
            end
          end
        end
      elsif field_type == "boolean_box"
        value ? @data["Yes"] += 1 : @data["No"] += 1
      else
        if value.present?
          value = value.gsub("\r\n", " ") if field_type == 'textarea'
          if @data[value].present?
            @data[value] += 1
          end
        end
      end
    end

    @data = @data.sort_by{|k, v| v}
    @data = @data.reject{|k, v| v < 1}
    if @data.present?
      @data.reverse!
    end

    if field_type == "datetime" || field_type == "date"
      @daily_data = Hash.new(0)
      @monthly_data = Hash.new(0)
      @yearly_data = Hash.new(0)
      @data.each do |x|
        daily = x[0].to_datetime.beginning_of_day
        monthly = x[0].to_datetime.beginning_of_month
        yearly = x[0].to_datetime.beginning_of_year
        @daily_data[daily] += x[1]
        @monthly_data[monthly] += x[1]
        @yearly_data[yearly] += x[1]
      end
      @daily_data = @daily_data.sort_by{|k,v| k}
      @monthly_data = @monthly_data.sort_by{|k,v| k}
      @yearly_data = @yearly_data.sort_by{|k,v| k}
      render :partial => "/queries/charts/datetime_chart_view"
    elsif field_type == "user"
      @data = @data.map{|k, v| [(User.find(k).full_name rescue (show_empty_value ? "*No Input" : nil)), v]}
      render :partial => "/queries/charts/chart_view"
    else
      render :partial => "/queries/charts/chart_view"
    end

  end


  private


  def load_options
    @types = BaseConfig::MODULES[session[:mode]][:objects].invert
    @templates = Template.where("archive = 0").sort_by{|x| x.name}.map{|template| [template.name, template.id]}.to_h
  end


  def apply_query
    @title = BaseConfig::MODULES[session[:mode]][:objects][@owner.target].pluralize
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')

    @target_fields = @object_type.get_meta_fields('show', 'index').keep_if{|x| x[:field]}

    @template_fields = []
    Template.where(:id => @owner.templates).map(&:fields).flatten.uniq{|field| field.label}.each{|field|
      @template_fields << {
        title: field.label,
        field: field.label,
        data_type: field.data_type,
        field_type: field.display_type,
      }
    }

    @fields = @target_fields + @template_fields

    if @title == "Submissions"
      records = @object_type.preload(:submission_fields).where(:templates_id => @owner.templates)
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
        case field[:display_type]
        when 'employee'
          matching_users = User.where("full_name = ?", search_value).map(&:id)
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
        case field[:display_type]
        when 'employee'
          matching_users = User.where("full_name LIKE ?", "%#{search_value}%").map(&:id)
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
      when 'boolean_box'
        return records.select{|record| xor ^ ((record.send(field[:field]) ? 'Yes' : 'No').downcase == search_value.downcase)}
      when 'checkbox'
        return records.select{|record| xor ^ (record.send(field[:field]).reject(&:empty?).join("").to_s.downcase == search_value.downcase)}
      when 'user'
        matching_users = User.where("full_name = ?", search_value).map(&:id)
        return records.select{|record| xor ^ (matching_users.include? record.send(field[:field]))}
      when 'date'
        start_date = search_value.split("to")[0]
        end_date = search_value.split("to")[1] || search_value.split("to")[0]
        return records.select{|x| xor ^ ((x.send(field[:field]) >= start_date.to_date && x.send(field[:field]) <= end_date.to_date) rescue false)}
      else
        return records.select{|record| xor ^ (record.send(field[:field]).to_s.downcase == search_value.to_s.downcase)}
      end
    when "contains"
      case field[:type]
      when 'boolean_box'
        return records.select{|record| xor ^ ((record.send(field[:field]) ? 'Yes' : 'No').downcase == search_value.downcase)}
      when 'user'
        matching_users = User.where("full_name LIKE ?", "%#{search_value}%").map(&:id)
        return records.select{|record| xor ^ (matching_users.include? record.send(field[:field]))}
      when 'date'
        start_date = search_value.split("to")[0]
        end_date = search_value.split("to")[1] || search_value.split("to")[0]
        return records.select{|x| xor ^ ((x.send(field[:field]) >= start_date.to_date && x.send(field[:field]) <= end_date.to_date) rescue false)}
      else
        return records.select{|record| xor ^ ((record.send(field[:field]).to_s.downcase.include? search_value.downcase) rescue false)}
      end
    when "numeric"
      case field[:type]
      when 'date'
        dates = search_value.split("to")
        if dates.length > 1
          start_date = dates[0]
          end_date = dates[1]
          return records.select{|x| xor ^ ((x.send(field[:field]) >= start_date.to_date && x.send(field[:field]) <= end_date.to_date) rescue false)}
        else
          date = dates[0]
          return records.select{|x| xor ^ ((x.send(field[:field]) >= date.to_date) rescue false)}
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


end
