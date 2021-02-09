module QueriesHelper

  # returns the formatted values of record's field
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

      if value.present? && field[:field].downcase.include?('get_source')
        value = value.split.first
      end
    end
    format_val(value, field_type, field_arr[1])
  end


  # helper for get_val: formats value based on field type
  def format_val(value, field_type, field_param=nil)
    case field_type
    when 'user', 'employee'
      User.find_by_id(value).full_name rescue value
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


  # returns an array that stores x_axis and series value pairs
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
        res << {x_axis: x_val[0], series: y_val[0], id: record.id}
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


  # return 2D hash of x_axis and series values
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


  def get_data_table_for_google_visualization_with_series(x_axis_field_arr:, series_field_arr:, records:, get_ids:)
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
    row1 = [params[:x_axis]] << series.sort
    data = [row1.flatten]
    x_axis.sort.each do |x|
      data << series.sort.inject([x]){|arr, y| arr << (data_hash[x][y] || 0)}
    end

    return data
  end


  def get_data_table_for_google_visualization(x_axis_field_arr:, records:)
    # x_axis_field_arr has only one hash inside
    x_axis_field_title = x_axis_field_arr[0][:title].nil? ? x_axis_field_arr[0][:label] : x_axis_field_arr[0][:title]

    data = [[x_axis_field_title, 'Count']]

    records.map{|record| get_val(record, x_axis_field_arr)}
      .compact.flatten
      .reject(&:blank?)
      .inject(Hash.new(0)){|h, e| h[e] += 1; h}
      .sort_by{|k,v| k}
      .each{|pair| data << pair}

    return data
  end


  def get_data_ids_table_for_google_visualization(x_axis_field_arr:, records:)
    # x_axis_field_arr has only one hash inside
    x_axis_field_title = x_axis_field_arr[0][:title].nil? ? x_axis_field_arr[0][:label] : x_axis_field_arr[0][:title]

    data_ids = [[x_axis_field_title, 'IDs']]
    records.map{|record| [record.id, get_val(record, x_axis_field_arr)] }
      .reject{ |x| x[1].nil? } # remove empty records
      .inject(Hash.new([])) { |hash, element|
        record_id = element[0]
        x_axis_field_value = element[1]

        if hash[x_axis_field_value].present?
          hash[x_axis_field_value] << record_id
        else
          hash[x_axis_field_value] = []
          hash[x_axis_field_value] << record_id
        end

        ; hash
      }
      .sort_by{|k,v| k}
      .each{|pair| data_ids << pair}

    return data_ids
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
    visualization_hash[:series] = "NA"
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


end
