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


def get_records
  adjust_session_to_target(@owner.target) if CONFIG.hierarchy[@module_name][:objects].exclude?(@owner.target)
  @title = CONFIG.hierarchy[@module_name][:objects][@owner.target][:title].pluralize
  @object_type = Object.const_get(@owner.target)
  @table_name = @object_type.table_name
  @headers = @object_type.get_meta_fields('index')
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


def get_val(record, field_arr)
  field = field_arr[0]
  if field.is_a?(Field)
    field_type = field.display_type
    if record.class == Submission
      value = SubmissionField.where(fields_id: field.id, submissions_id: record.id)[0].value rescue nil
    elsif record.class == Record
      value = RecordField.where(fields_id: field.id, records_id: record.id)[0].value rescue nil
    else
      value = 'Something Went Wrong'
    end
  else
    field_type = field[:type]
    value = strip_html_tag(record.send(field[:field]))
  end
  format_val(value, field_type, field_arr[1])
end


def strip_html_tag(text)
  text.gsub(/<\/?[^>]+>/, '') rescue text
end


def format_val(value, field_type, field_param=nil)
  case field_type
  when 'user', 'employee'
    User.find_by_id(value).full_name rescue 'N/A'
  when 'datetime', 'date'
    value.strftime("%Y-%m") rescue 'N/A'
  when 'boolean_box', 'boolean'
    (value ? 'Yes' : 'No') rescue 'No'
  when 'checkbox'
    value.split(';') rescue nil
  when 'list'
    value.split('<br>')
  when 'category'
    value.split('<br>').map{|x| x.split('>').map(&:strip)}.map{|x| x[field_param.to_i - 1] rescue nil}
  else
    value
  end
end


def create_hash_array(records, x_axis_field, series_field)
  arr = records.inject([]) do |res, record|
    x_val = get_val(record, x_axis_field)
    y_val = get_val(record, series_field)
    if x_val.is_a?(Array) && y_val.is_a?(Array)
      x_val.each do |x|
        y_val.each do |y|
          res << {x_axis: x, series: y, id: record.id}
        end
      end
    elsif x_val.is_a?(Array)
      x_val.each{|x| res << {x_axis: x, series: y_val, id: record.id}}
    elsif y_val.is_a?(Array)
      y_val.each{|y| res << {x_axis: x_val, series: y, id: record.id}}
    else
      res << {x_axis: x_val, series: y_val, id: record.id}
    end
    res
  end
  arr
end


def populate_hash(data_hash, x_axis, series, get_ids: false, record_id: nil)
  if get_ids
    if data_hash[x_axis] && data_hash[x_axis][series]
      data_hash[x_axis][series] << record_id
    elsif data_hash[x_axis]
      data_hash[x_axis][series] = []
      data_hash[x_axis][series] << record_id
    else
      data_hash[x_axis] = Hash.new
      data_hash[x_axis][series] = []
      data_hash[x_axis][series] << record_id
    end
  else # get count
    if data_hash[x_axis] && data_hash[x_axis][series]
      data_hash[x_axis][series] += 1
    elsif data_hash[x_axis]
      data_hash[x_axis][series] = 1
    else
      data_hash[x_axis] = Hash.new
      data_hash[x_axis][series] = 1
    end
  end
end


def get_data_visualization_with_series(x_axis_field_arr:, series_field_arr:, records:, get_ids:)
  # build array of hash to stores values for x_axis and series
  arr = create_hash_array(records, x_axis_field_arr, series_field_arr)
  # create a hash to store the occurences of each element
  data_hash = Hash.new

  arr.each do |record|
    x_axis = record[:x_axis].blank? ? 'N/A' : record[:x_axis]
    series = record[:series].blank? ? 'N/A' : record[:series]

    if x_axis.is_a?(Array) && series.is_a?(Array)
      x_axis.each do |x|
        series.each do |y|
          populate_hash(data_hash, x, y, get_ids: get_ids, record_id: record[:id])
        end
      end
    elsif x_axis.is_a?(Array)
      x_axis.each do |x|
        populate_hash(data_hash, x, series, get_ids: get_ids, record_id: record[:id])
      end
    elsif series.is_a?(Array)
      series.each do |y|
        populate_hash(data_hash, x_axis, y, get_ids: get_ids, record_id: record[:id])
      end
    else
      populate_hash(data_hash, x_axis, series, get_ids: get_ids, record_id: record[:id])
    end
  end

  # get first row and first column values
  series = data_hash.values.map(&:keys).flatten.uniq
  x_axis = data_hash.keys
  # creates final data array: 2-D array
  # row1 = [params[:x_axis]] << series.sort
  row1 = series.sort
  data = [row1.flatten]
  x_axis.sort.each do |x|
    data << series.sort.inject([x]){|arr, y| arr << (data_hash[x][y] || 0)}
  end

  return data
end


def get_data_visualization(x_axis_field_arr:, records:)
  # x_axis_field_arr has only one hash inside
  x_axis_field_title = x_axis_field_arr[0][:title].nil? ? x_axis_field_arr[0][:label] : x_axis_field_arr[0][:title]

  data = []

  records.map{|record| get_val(record, x_axis_field_arr)}
    .compact.flatten
    .reject(&:blank?)
    .inject(Hash.new(0)){|h, e| h[e] += 1; h}
    .sort_by{|k,v| k}
    .each{|pair| data << pair}

  return data
end



def get_data(visualization)
  @x_axis_field = get_field(@owner, @object_type, visualization.x_axis)

  if visualization.series.present?
    @series_field = get_field(@owner, @object_type, visualization.series)
    get_data_visualization_with_series(x_axis_field_arr: @x_axis_field,
                                       series_field_arr: @series_field,
                                       records: @records,
                                       get_ids: false)
  else
    get_data_visualization(x_axis_field_arr: @x_axis_field, records: @records)
  end
end


def get_query_detail_json(owner, total_records)
  attributes = @query_fields.map { |field| [field[:field], field[:field]] }.to_h

  {
    id: owner.id,
    title: owner.title,
    created_by: User.find(owner.created_by_id).full_name,
    target: owner.send(attributes["get_target"]),
    templates: owner.send(attributes["get_templates"]),
    total: total_records
  }
end


def get_visualization_w_series_json(data, visualization)
  visualization_hash = {}
  visualization_hash[:x_axis] = visualization.x_axis
  visualization_hash[:series] = visualization.series
  visualization_hash[:data] = {}

  series_names = data[0]
  x_axis_names_with_count = data[1..-1]

  x_axis_names_with_count.each do |x_axis|

    x_axis_name = x_axis[0]
    x_axis_counts = x_axis[1..-1]

    visualization_hash[:data][x_axis_name] = {}

    series_names.each_with_index do |series, index|
      visualization_hash[:data][x_axis_name][series] = x_axis_counts[index]
    end
  end

  visualization_hash
end


def get_visualization_wo_series_json(data, visualization)
  visualization_hash = {}
  visualization_hash[:x_axis] = visualization.x_axis
  visualization_hash[:series] = "N/A"
  visualization_hash[:data] = {}

  data.each do |x_axis|
    x_axis_name = x_axis[0]
    x_axis_count = x_axis[1]

    visualization_hash[:data][x_axis_name] = x_axis_count
  end

  visualization_hash
end


def get_visualizations_json(owner)
  query_result_visualizations = []

  owner.visualizations.each do |visualization|

    data = get_data(visualization)

    if visualization.series.present?
      query_result_visualizations << get_visualization_w_series_json(data, visualization)
    else
      query_result_visualizations << get_visualization_wo_series_json(data, visualization)
    end
  end

  query_result_visualizations
end


require 'net/sftp'
require 'stringio'

desc 'Export the query result as JSON'
task export_query_result: :environment do

  #------------------------------#
  host = "secure.flyfrontier.com"
  username = "F9ProsafeT"
  password = "OwTX4NX&"
  #------------------------------#

  all_queries_result = {}
  @query_fields = Query.get_meta_fields('show')

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

  Net::SFTP.start(host, username, :password => password) do |sftp|
    begin
      io = StringIO.new all_queries_result.to_json
      file_name = "#{Time.current.strftime("%Y%m%d%H%M")}.json"
      target = "/Usr/F9ProsafeT/Incoming/#{file_name}"

      sftp.upload!(io, target)

      p 'UPLOAD SUCCESSFUL'
    rescue Exception => e
      p e.message
      p 'UPLOAD FAILED'
    end
  end

end
