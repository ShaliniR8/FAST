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
    @owner = Query.create(params[:query])
    params[:base].each_pair{|index, condition| create_query_condition(condition, @owner.id, nil)} rescue nil
    redirect_to query_path(@owner)
  end

  def update
    @owner = Query.find(params[:id])
    @owner.update_attributes(params[:query])
    @owner.query_conditions.destroy_all
    params[:base].each_pair{|index, condition| create_query_condition(condition, @owner.id, nil)} rescue nil
    redirect_to query_path(@owner)
  end

  # on target select, load conditions block
  def load_conditions_block
    @owner = params[:query_id].present? ? Query.find(params[:query_id]) : Query.new
    @target = params[:target]
    @target_display_name = params[:target_display_name]
    @fields = Object.const_get(@target).get_meta_fields('show', 'index').keep_if{|x| x[:field]}
    @logical_types = ['Equals To', 'Not Equal To', 'Contains', 'Does Not Contain', '>=', '<']
    @operators = ["AND", "OR"]
    render :partial => "building_query"
  end

  # add visualization box to query
  def add_visualization
    @owner = Query.find(params[:id])
    @object_type = Object.const_get(@owner.target)
    @fields = @object_type.get_meta_fields('show', 'index').keep_if{|x| x[:field]}
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
    @owner.visualizations.delete(params["field_id"])
    @owner.save
    render :json => true
  end

  # draws charts
  def generate_visualization

    show_empty_value = false

    @owner = Query.find(params[:id])

    @title = @owner.target
    @object_type = Object.const_get(@title)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    @fields = @object_type.get_meta_fields('show', 'index').keep_if{|x| x[:field]}

    records = params[:records].split(",") || []

    @result = @object_type.where(:id => records)
    @label = params[:field_name]

    visualization_index = @owner.visualizations.index(params["field_id"].titleize) ||
      @owner.visualizations.index(params["field_name"])

    @owner.visualizations[visualization_index] = @label
    @owner.save

    @field = @object_type.get_meta_fields('show', 'index')
      .select{|header| header[:title] == @label}.first

    result_id = []
    @result.each{ |r| result_id << r.id }

    # Create Hash to store value and occurance
    @data = Hash.new

    # Create Hash for each checkbox options
    if @field[:type] == "checkbox"
      temp_hash = Hash.new
      temp_hash = Hash[@field[:options].collect{|item| [item, 0]}]
      @data = @data.merge(temp_hash)

    elsif @field[:type] == "boolean_box"
      @data["Yes"] = 0
      @data["No"] = 0

    # Create key value pair for unique values
    else
      @data = Hash[
        @result
          .map{|x| x.send(@field[:field])}
          .compact
          .uniq
          .collect{|item| [item, 0]}
      ]
    end
    @data["*No Input"] = 0 if show_empty_value

    # Iterate through result to update Hash
    @result.each do |r|
      value = r.send(@field[:field])
      value = value.present? ? value : (show_empty_value ? "*No Input" : nil)
      if @field[:type] == 'checkbox'
        if value.present?
          value.each do |v|
            if @data[v].present?
              @data[v] += 1
            end
          end
        end
      elsif @field[:type] == "boolean_box"
        value ? @data["Yes"] += 1 : @data["No"] += 1
      else
        if value.present?
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

    if @field[:type] == "datetime" || @field[:type] == "date"
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
    elsif @field[:type] == "user"
      @data = @data.map{|k, v| [(User.find(k).full_name rescue (show_empty_value ? "*No Input" : nil)), v]}
      render :partial => "/queries/charts/chart_view"
    else
      render :partial => "/queries/charts/chart_view"
    end

  end


  private

  def load_options
    @types = BaseConfig::MODULES[session[:mode]][:objects].invert
  end

  def apply_query
    @title = BaseConfig::MODULES[session[:mode]][:objects][@owner.target].pluralize
    @object_type = Object.const_get(@owner.target)
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    @fields = @object_type.get_meta_fields('show', 'index').keep_if{|x| x[:field]}
    records = @object_type.select{|x| ((defined? x.template) && x.template.present?) ? !x.template : true}
    results = []
    @owner.query_conditions.each do |condition|
      records = records & expand_emit(condition, records)
    end
    @records = records
  end

  def expand_emit(condition, records, operator=nil)
    results = []
    if condition.query_conditions.length > 0
      if condition.operator == "AND"
        results = records
        condition.query_conditions.each do |sub_condition|
          results = results & expand_emit(sub_condition, records)
        end
      elsif condition.operator == "OR"
        condition.query_conditions.each do |sub_condition|
          results = results | expand_emit(sub_condition, records)
        end
      end
    else
      results = emit(condition, records)
    end
    results
  end

  def emit(condition, records)
    field = @fields.select{|header| header[:title] == condition.field_name}.first
    if condition.value.present?
      case condition.logic
      when "Equals To" then results = emit_helper(condition.value, records, field, false, "equals")
      when "Not Equal To"then results = emit_helper(condition.value, records, field, true, "equals")
      when "Contains"then results = emit_helper(condition.value, records, field, false, "contains")
      when "Does Not Contain"then results = emit_helper(condition.value, records, field, true, "contains")
      when ">="then results = emit_helper(condition.value, records, field, false, "numeric")
      when "<"then results = emit_helper(condition.value, records, field, true, "numeric")
      else results = records
      end
    else
      case condition.logic
      when "Equals To" then results = records.select{|record| record.send(field[:field]) == ""}
      when "Not Equal To" then results = records.select{|record| record.send(field[:field]) != ""}
      when "Contains" then results = records
      when "Does Not Contain" then results = []
      else results = []
      end
    end
    return results
  end

  def emit_helper(search_value, records, field, xor, logic_type)
    case logic_type
    when "equals"
      case field[:type]
      when 'boolean_box'
        return records.select{|record| xor ^ ((record.send(field[:field]) ? 'Yes' : 'No').downcase == search_value.downcase)}
      when 'user'
        matching_users = User.where("full_name = ?", search_value).map(&:id)
        return records.select{|record| xor ^ (matching_users.include? record.send(field[:field]))}
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
