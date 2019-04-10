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

class QueryStatementsController < ApplicationController



  def load_options
    @templates = Template.find(:all)
    @categories = Category.find(:all)
    if session[:mode] == "ASAP"
      @fields = Field.find(:all)
    else
      @fields = []
      fields = get_fields_by_class
      fields.each do |k,v|
        v.each do |vk,vv|
          @fields.push({:name => vk, :value => vv, :class => k})
        end
      end
    end
    @condition_types = ['And','Or','Negation']
    @logical_types = [
      'Required',
      'Optional',
      'Negation',
      'Greater than',
      'Less than'
    ]
    @classes = get_classes_by_module
    Rails.logger.info @classes.inspect
  end



  def index 
    start = Time.now
    @headers=QueryStatement.get_headers
    @records=QueryStatement.find(:all)
    @table_name="query_statements"
    @title="Queries"
    finish = Time.now
    puts "------------------ query statement index: #{finish - start}"
  end



  def new
    load_options
    @privileges = Privilege.find(:all)
    @title = "New Query"
    @query = QueryStatement.new
  end



  def create

    params[:query_statement][:query_conditions_attributes].each_value do |field|
      if field[:value].is_a?(Array)
        field[:value].delete("")
        field[:value] = field[:value].join(";")
      end
    end
    query=QueryStatement.new(params[:query_statement])
    query.user_id=current_user.id
    if query.save
      redirect_to  query_statement_path(query)
    end
  end



  def update
    query=QueryStatement.find(params[:id])
    if query.update_attributes(params[:query_statement])
      redirect_to query_statement_path(query)
    end
  end



  def edit
    load_options
      @privileges=Privilege.find(:all)
    @query=QueryStatement.find(params[:id])
    @title="Edit Query : #{@query.title}"
  end




  def copy
    redirect_to query_statement_path(QueryStatement.find(params[:id]).duplicate)
  end




  # generate data for visualization chart (All templates)
  # params[:field_label] : field label
  # params[:template_id] : template ID array
  # params[:chart] : chart type
  def analytic_data_all
    @query = QueryStatement.find(params[:id])
    @target_class = Object.const_get(@query.target_class)

    # Get template list
    templates = params[:template_id].split(",")
    templates = templates[2..-1]

    # Get items from the result table
    @candidates = @target_class.where(:templates_id => templates)

    conditions = @query.query_conditions.where(:template_id => templates)
    @result = []

    # Get fields id with selected label
    if session[:mode] == "ASAP"
      if @query.query_conditions.present?
        @query.query_conditions.group_by{|x| x.template_id}.each_pair do |t,conditions|
          @candidates = @target_class.where("templates_id = ?", t)
          templates.push(t)
          @result.concat(@candidates.select{|x| x.satisfy(conditions)})
        end
      else
        @result = @target_class.find(:all)
      end
    else
    end

    @label = params[:field_label]
    @fields = Field.where(:label => params[:field_label] )
    @fields.keep_if{|f| templates.include?(f.category.template.id.to_s) }
    @field = @fields.first
    result_id = []
    @result.each{ |r| result_id << r.id }

    # Create Hash to store value and occurance
    @data = Hash.new
    @fields_id = @fields.collect{|x| x.id}
    fields = SubmissionField.where(:fields_id => @fields_id, :submissions_id => result_id)
    # Create Hash for each checkbox options
    if @field.display_type == "checkbox"
      @fields.each do |f|
        hash = Hash.new
        hash = Hash[f.getOptions.collect { |item| [item, 0] } ]
        print f.category.template.id
        @data = @data.merge(hash)

      end
    # Create key value pair for unique values
    else
      if @query.target_class == "Submission"
        @data = Hash[ SubmissionField.where(:fields_id => @fields_id, :submissions_id => result_id).select(:value).map(&:value).uniq.collect { |item| [ item, 0 ] } ]
      elsif @query.target_class == "Record"
        @data = Hash[ RecordField.where(:fields_id => @fields.collect{|x| x.id}, :records_id => result_id).select(:value).map(&:value).uniq.collect { |item| [ item, 0 ] } ]
      end
    end

    # Iterate through result to update Hash
    Rails.logger.info @data.inspect
    @result.each do |r|
      value = r.get_field_by_label(@label)
      if value.present?
        # Split value if field is checkbox
        if @field.display_type == "checkbox"
          value.split(";").each do |option|
            if @data[option] != nil
              @data[option] += 1
            end
          end
        else
          @data[value] += 1
        end
      end
    end
    @data = @data.sort_by{|k, v| v}
    @data = @data.reject{|k, v| v < 1}
    if @data.present?
      @data.reverse!
    end
    render :partial => "chart_and_grid"
  end

  # generate data for visualization chart (selected template)
  # params[:field_id] : field id
  # params[:template_id] : template id
  # params[:chart] : chart type
  def analytic_data
    @query = QueryStatement.find(params[:id])
    @target_class = Object.const_get(@query.target_class)
    @candidates = @target_class.where('templates_id = ?', params[:template_id])
    conditions = @query.query_conditions.where('template_id = ?', params[:template_id])
    @result = []
    if session[:mode] == "ASAP"
      if conditions.present?
        @result.concat( @candidates.select{ |x| x.satisfy(conditions)})
      else
        @result = @target_class.find(:all)
      end
    end
    @field = Field.find(params[:field_id])
    @label = @field.label
    result_id = []
    @result.each{ |r| result_id << r.id }
    @data = Hash.new
    if @field.display_type == "checkbox"
      @data = Hash[@field.getOptions.collect { |item| [item, 0] } ]
    else
      if @query.target_class == "Submission"
        @data = Hash[ SubmissionField.where(:fields_id => params[:field_id], :submissions_id => result_id).map(&:value).uniq.collect { |item| [ item, 0 ] } ]
      elsif @query.target_class == "Record"
        @data = Hash[ RecordField.where(:fields_id => params[:field_id], :records_id => result_id).map(&:value).uniq.collect { |item| [ item, 0 ] } ]
      end
    end
    @result.each do |r|
      value = r.get_field(params[:field_id])
      if value.present?
        if @field.display_type == "checkbox"
          value.split(";").each do |option|
            if @data[option] != nil
              @data[option] = @data[option] + 1
            end
          end
        else
          @data[value] = @data[value] + 1
        end
      end
    end
    @data = @data.sort_by{|k, v| v}
    @data = @data.reject{|k, v| v < 1}
    if @data.present?
      @data.reverse!
    end
    render :partial => "chart_and_grid"
  end

  # Generate data for pupulating visualization drill down table (All templates)
  # params[:value] : field value
  # params[:field_label] : field label
  def visualization_table_all
    value = params[:value]
    @query = QueryStatement.find(params[:id])
    target_class = Object.const_get(@query.target_class)
    @headers = target_class.get_headers
    result = []
    templates = []

    # Get fields id with selected label
    if session[:mode] == "ASAP"
      if @query.query_conditions.present?
        @query.query_conditions.group_by{|x| x.template_id}.each_pair do |t, conditions|
          candidates = target_class.where("templates_id = ?", t)
          templates.push(t)
          result.concat(candidates.select{|x| x.satisfy(conditions)})
        end
      else
        templates = Template.find(:all)
        result = target_class.find(:all)
      end
      @records = result
      @headers = target_class.get_headers
      @table_name = @query.target_class.pluralize.downcase
      @templates = templates.map{|x| Template.find(x)}
      @fields = []
      @templates.each do |template|
        template.categories.each do |category|
          if category.analytic_fields.present?
            @fields.push(category)
          end
        end
      end
      @charts = ['Bar','Pie']
    end
    @fields = Field.where(:label => params[:field_label])
    @field = @fields.first
    @title = params[:field_label] + ": " + value
    target = @query.target_class
    @fields_id = @fields.collect{|x| x.id}
    result_id = []
    result.each{ |x| result_id << x.id }

    # Get submission/record fields with selected fields and value
    if target == "Submission"
      if @field.display_type == "checkbox"
        report_fields = SubmissionField.where(:fields_id => @fields_id, :submissions_id => result_id)
        query = "value like \"%#{value}%\""
        report_fields = report_fields.where(query)
      else
        report_fields = SubmissionField.where(:fields_id => @fields_id, :submissions_id => result_id, :value => value)
      end
    else
      if @field.display_type == "checkbox"
        report_fields = RecordField.where(:fields_id => @fields_id, :records_id => result_id)
        query = "value like \"%#{value}%\""
          report_fields = report_fields.where(query)
      else
        report_fields = RecordField.where(:fields_id => @fields_id, :records_id => result_id, :value => value)
      end
    end
    report_ids = []
    report_fields.each do |x| 
      if target == "Submission"
        report_ids << x[:submissions_id]
      else
        report_ids << x[:records_id]
      end
    end
    @records = @records.select{|x| report_ids.include?(x[:id]) }
    if target == "Submission"
      render "submissions/index"
    else
      render "records/index"
    end
  end

  # Generate data for pupulating visualization drill down table (selected template)
  # params[:value] : field value
  # params[:field_id] : field id
  def visualization_table
    value = params[:value]    
    @query = QueryStatement.find(params[:id])
    target_class = Object.const_get(@query.target_class)
    @headers = target_class.get_headers
    result = []
    templates = []
    if session[:mode] == "ASAP"
      if @query.query_conditions.present?
        @query.query_conditions.group_by{|x| x.template_id}.each_pair do |t,conditions|
          candidates = target_class.where("templates_id = ?", t)
          templates.push(t)
          result.concat(candidates.select{|x| x.satisfy(conditions)})
        end
      else
        result = target_class.find(:all)
      end
      @records = result
      @headers = target_class.get_headers
      @table_name = @query.target_class.pluralize.downcase
      @templates = templates.map{|x| Template.find(x)}
      @fields = []
      @templates.each do |template|
        template.categories.each do |category|
          if category.analytic_fields.present?
            @fields.push(category)
          end
        end
      end
      @charts = ['Bar','Pie']
    else
    end
    @field = Field.find(params[:field_id])
    @title = @field.label + ": " + value
    target = @query.target_class
    if target == "Submission"
      if @field.display_type == "checkbox"
        report_fields = SubmissionField.where(:fields_id => @field.id)
        query = "value like \"%#{value}%\""
        report_fields = report_fields.where(query)
      else
        report_fields = SubmissionField.where("fields_id = ? and value = ?", @field.id, value)
      end
    else
      if @field.display_type == "checkbox"
        report_fields = RecordField.where("fields_id = ?", @field.id)
        query = "value like \"%#{value}%\""
        report_fields = report_fields.where(query)
      else
        report_fields = RecordField.where("fields_id = ? and value = ?", @field.id, value)
      end
    end
    #submission_fields = SubmissionField.where(:fields_id => @field.id, :value => value)
    report_ids = []
    report_fields.each do |x| 
      if target == "Submission"
        report_ids << x[:submissions_id]
      else
        report_ids << x[:records_id]
      end
    end
    @records = @records.select{|x| report_ids.include?(x[:id]) }
    #render :partial => "visualization_list"
    if target == "Submission"
      render "submissions/index"
    else
      render "records/index"
    end
  end

  def show
    @title = "Query Result"
    @query = QueryStatement.find(params[:id])
    target_class = Object.const_get(@query.target_class)
    @headers = target_class.get_headers
    @table_name = @query.target_class.pluralize.downcase
    result = []
    templates = []
    if session[:mode] == "ASAP"
      all_query_conditions = @query.query_conditions
      if all_query_conditions.present?
        all_query_conditions.group_by{|x| x.template_id}.each_pair do |t, conditions|
          if @query.target_class == "Submission"
            candidates = target_class.where("templates_id = ? and completed = 1", t)
          else
            candidates = target_class.where("templates_id = ?", t)
          end
          templates.push(t)
          result.concat(candidates.select{|x| x.satisfy(conditions)})
        end
      else
        result = target_class.find(:all)
        templates = Template.where(:id => result.map(&:templates_id))
      end
      @records = result
      @templates = templates.map{|x| Template.find(x)}
      @fields = []
      @templates.each do |template|
        template.categories.each do |category|
          if category.analytic_fields.present?
            @fields.push(category)
          end
        end
      end   
    end
  end

  def detailed_values
    @field = Field.find(params[:field_id])
    render :partial => "detailed_value"
  end

  def destroy
    query=QueryStatement.find(params[:id]).destroy
    redirect_to query_statements_path, flash: {danger: "Query ##{params[:id]} deleted."}
  end

  def analyze_field
  end

  
end
