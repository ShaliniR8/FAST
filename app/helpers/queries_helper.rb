module QueriesHelper

  def format_val(value, field_type, field_param=nil)
    case field_type
    when 'user', 'employee'
      if value.is_a? Integer
        User.find_by_id(value).full_name rescue ''
      else
        User.find_by_full_name(value).full_name rescue ''
      end
    when 'datetime', 'date'
      value.strftime("%Y-%m") rescue 'N/A'
    when 'boolean_box', 'boolean'
      (value ? 'Yes' : 'No') rescue 'No'
    when 'checkbox'
      value.split(';').map(&:strip).map{|val| val.gsub("\"", '')} rescue nil
    when 'list'
      value.split('<br>').map(&:strip) rescue nil
    when 'category'
      value.split('<br>').map{|x| x.split('>').map(&:strip)}.map{|x| x[field_param.to_i - 1] rescue nil}
    else
      if value.is_a? Integer
        value
      else
        value.strip.gsub("\"", '') rescue ''
      end
    end
  end


  def populate_hash_to_be_created(res, x_val, y_val, record_id)
    if x_val.is_a?(Array) && y_val.is_a?(Array)
      x_val.each do |x|
        y_val.each do |y|
          res << {x_axis: x, series: y, id: record_id}
        end
      end
      res << {x_axis: x_val[0], series: y_val[0], id: record_id}
    elsif x_val.is_a?(Array)
      x_val.each{|x| res << {x_axis: x, series: y_val, id: record_id}}
    elsif y_val.is_a?(Array)
      y_val.each{|y| res << {x_axis: x_val, series: y, id: record_id}}
    else
      res << {x_axis: x_val, series: y_val, id: record_id}
    end
    return res
  end


  # return 2D hash of x_axis and series values
  def populate_hash(data_hash, x_axis, series, get_ids: false, record_id: nil)
    if get_ids
      if data_hash[x_axis] && data_hash[x_axis][series]
        data_hash[x_axis][series] << record_id if data_hash[x_axis][series].exclude?(record_id)
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


  def get_data_table_for_google_visualization_with_series(x_axis_field_name:, x_axis_field_arr:, series_field_arr:, records_ids:, get_ids:, query:)
    # build array of hash to stores values for x_axis and series
    arr = create_hash_array_sql(x_axis_field_arr, series_field_arr, records_ids, get_ids, query)
    # create a hash to store the occurences of each element
    data_hash = Hash.new
    added_pairs = Hash.new

    arr.each do |record|
      x_axis = record[:x_axis].blank? ? 'N/A' : record[:x_axis]
      series = record[:series].blank? ? 'N/A' : record[:series]
      pair = [x_axis, series]

      if !added_pairs.has_key?(record[:id]) || added_pairs[record[:id]].exclude?(pair)
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

        if added_pairs.has_key?(record[:id])
          added_pairs[record[:id]] << pair
        else
          added_pairs[record[:id]] = []
          added_pairs[record[:id]] << pair
        end
      end
    end

    # get first row and first column values
    series = data_hash.values.map(&:keys).flatten.uniq
    x_axis = data_hash.keys

    # creates final data array: 2-D array
    row1 = [x_axis_field_name] << series.sort
    data = [row1.flatten]
    x_axis.sort.each do |x|
      data << series.sort.inject([x]){|arr, y| arr << (data_hash[x][y] || 0)}
    end

    return data
  end


  def create_hash_array_sql(x_axis_field_arr, series_field_arr, records_ids, get_ids, query)
    x_vals_by_id = get_mapped_data_for_field(field_arr: x_axis_field_arr, records_ids: records_ids, query: query)
    y_vals_by_id = get_mapped_data_for_field(field_arr: series_field_arr, records_ids: records_ids, query: query)
    res = []

    records_ids.each do |rid|
      x_vals = x_vals_by_id[rid.to_i]
      y_vals = y_vals_by_id[rid.to_i]
      res = populate_hash_to_be_created(res, x_vals, y_vals, rid)
    end

    res
  end


  def get_mapped_data_for_field(field_arr:, records_ids:, query:)
    target = query.target
    field_title = field_arr[0][:title].nil? ? field_arr[0][:label] : field_arr[0][:title]
    field = field_arr[0]
    field_param = field_arr[1]
    values = Hash.new

    if field.is_a?(Field)
      field_type = field.display_type
      fields_ids = Template.preload(:categories, :fields).where(id: query.templates).map(&:fields).flatten.select{|x| x.label == field_title}.map(&:id)
      values = Hash.new { |h, k| h[k] = [] }

      if target == 'Report'
        sr_records = Record.find_by_sql("SELECT records.id FROM records WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:id) rescue []

        Record.find_by_sql("SELECT records.reports_id, record_fields.value FROM records INNER JOIN record_fields ON records.id = record_fields.records_id
                            WHERE (record_fields.fields_id IN (#{fields_ids.join(',')})
                            AND record_fields.records_id #{sr_records.present? ? "IN (#{sr_records.join(',')})" : "IS NULL"})")
                            .map{|r| values[r.reports_id] << format_val(r.value, field_type, field_param)} rescue {}

      elsif target == 'Record'
        RecordField.find_by_sql("SELECT record_fields.records_id, record_fields.value FROM record_fields WHERE record_fields.fields_id IN (#{fields_ids.join(',')}) AND
                                record_fields.records_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                .map{|r| values[r.records_id] << format_val(r.value, field_type, field_param)} rescue {}

      elsif target == 'Submission'
        SubmissionField.find_by_sql("SELECT submission_fields.submissions_id, submission_fields.value FROM submission_fields WHERE submission_fields.fields_id IN (#{fields_ids.join(',')}) AND
                                    submission_fields.submissions_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                    .map{|r| values[r.submissions_id] << format_val(r.value, field_type, field_param)} rescue {}
      end
    else
      field_type = field[:type]
      field_name = map_condition_field(target, field[:title])
      object_type = Object.const_get(target)

      case field_name
      when 'additional_info'
        values = Hash.new { |h, k| h[k] = [] }
        if target == 'Report'
          sr_records = Report.find_by_sql("SELECT records.id FROM records WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:id) rescue []

          sr_record_fields = RecordField.find_by_sql("SELECT record_fields.id FROM record_fields INNER JOIN fields ON record_fields.fields_id = fields.id
                                                      WHERE (record_fields.records_id #{sr_records.present? ? "IN (#{sr_records.join(',')})" : "IS NULL"} AND fields.additional_info = 1)")
                                                      .map(&:id) rescue []

          Record.find_by_sql("SELECT records.reports_id, record_fields.value FROM records INNER JOIN record_fields ON record_fields.records_id = records.id
                                      WHERE record_fields.id #{sr_record_fields.present? ? "IN (#{sr_record_fields.join(',')})" : "IS NULL"}").map{|r| values[r.reports_id] << r.value} rescue {}

        else
          RecordField.find_by_sql("SELECT record_fields.records_id, record_fields.value FROM record_fields INNER JOIN fields ON record_fields.fields_id = fields.id
                                            WHERE (record_fields.records_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"} AND
                                            fields.additional_info = 1)").map{|r| values[r.records_id] << r.value} rescue {}

        end

      when 'record_type'
        table_name = object_type.table_name
        values = Template.find_by_sql("SELECT templates.name, #{table_name}.id FROM templates INNER JOIN #{table_name} ON #{table_name}.templates_id = templates.id
                                       WHERE #{table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map{|r| [r.id, r.name]}.to_h rescue {}

      when 'included_reports'
        values = Record.find_by_sql("SELECT records.reports_id, CONCAT(\'#\', records.id, \' (\', templates.name, \')\') AS inc_report FROM records
                                    INNER JOIN templates ON records.templates_id = templates.id WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                    .map{|r| [r.reports_id, r.inc_report]}.to_h rescue {}

      when 'included_reports_types'
        values = Record.find_by_sql("SELECT records.reports_id, templates.name FROM records INNER JOIN templates ON records.templates_id = templates.id
                                    WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map{|r| [r.reports_id, r.name]}.to_h rescue {}

      when 'included_occurrences', 'included_findings', 'source_of_input', 'meeting_host'
        temp_values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        temp_values.each do |temp_val|
          t_val = strip_html_tag(temp_val.send(field[:field].to_sym))
          if t_val.present? && field[:field].downcase.include?('get_source')
            t_val = t_val.split.first
          end
          t_val = format_val(t_val, field_type, field_param)

          values[temp_val.id] = t_val
        end

      when 'included_verifications'
        values = Verification.find_by_sql("SELECT verifications.owner_id, CONCAT(verifications.status, \', \', verifications.verify_date) AS ver_status FROM verifications WHERE
                                          (verifications.owner_type = \'#{target}\' AND verifications.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})")
                                          .map{|r| [r.owner_id, r.ver_status]}.to_h rescue {}

      when 'cause_label'
        values = Hash.new { |h, k| h[k] = [] }
        Cause.find_by_sql("SELECT causes.owner_id, CONCAT(causes.category, \' > \', causes.attr) AS cause_label FROM causes WHERE
                                    (causes.owner_type = \'#{target}\' AND causes.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})")
                                    .map{|r| values[r.owner_id] << r.cause_label} rescue {}

      when 'cause_value'
        values = Hash.new { |h, k| h[k] = [] }
        Cause.find_by_sql("SELECT causes.owner_id, causes.value FROM causes WHERE (causes.owner_type = \'#{target}\'
                                    AND causes.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})")
                                    .map{|r| values[r.owner_id] << (r.value.present? ? (['Audit', 'Inspection'].exclude?(query.target) ? (r.value == 1 ? 'Yes' : (r.value == 0 ? 'No' : r.value)) : r.value) : "")} rescue {}

      when 'initial_risk_score'
        values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                          .map{|r| [r.id, r.get_risk_score]}.to_h rescue {}

      when 'mitigated_risk_score'
        values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                          .map{|r| [r.id, r.get_risk_score_after]}.to_h rescue {}

      when 'risk_severity', 'risk_severity_after', 'risk_likelihood', 'risk_likelihood_after'
        field_name = field_name.gsub('risk_', '')

        if field_name.include?('severity')
          arr = CONFIG::MATRIX_INFO[:severity_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
        else
          arr = CONFIG::MATRIX_INFO[:probability_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
        end

        values = object_type.find_by_sql("SELECT #{object_type.table_name}.id, #{object_type.table_name}.#{field_name} FROM #{object_type.table_name}
                                          WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                          .map{|r| [r.id, (r.send(field_name).present? ? arr[r.send(field_name).to_i].gsub('&nbsp;', ' ') : nil)]}.to_h rescue {}

      when 'users_id'
        if CONFIG::GENERAL[:sabre_integration].present?
          values = User.find_by_sql("SELECT CONCAT(users.full_name, \' (\', users.employee_number, \')\') AS full_name, records.id FROM users INNER JOIN records ON records.users_id = users.id
                                    WHERE records.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                    .map{|r| [r.id, r.full_name]}.to_h rescue {}
        else
          values = User.find_by_sql("SELECT users.full_name, records.id FROM users INNER JOIN records ON records.users_id = users.id
                                    WHERE records.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                    .map{|r| [r.id, r.full_name]}.to_h rescue {}
        end

      when 'user_id'
        if CONFIG::GENERAL[:sabre_integration].present?
          values = User.find_by_sql("SELECT CONCAT(users.full_name, \' (\', users.employee_number, \')\') AS full_name, submissions.id FROM users INNER JOIN submissions ON submissions.user_id = users.id
                                     WHERE submissions.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                     .map{|r| [r.id, r.full_name]}.to_h rescue {}
        else
          values = User.find_by_sql("SELECT users.full_name, submissions.id FROM users INNER JOIN submissions ON submissions.user_id = users.id
                                     WHERE submissions.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                     .map{|r| [r.id, r.full_name]}.to_h rescue {}
        end

      when 'responsible_user_id', 'approver_id', 'created_by_id'
        table_name = object_type.table_name
        values = User.find_by_sql("SELECT users.full_name, #{table_name}.id FROM users INNER JOIN #{table_name} ON #{table_name}.#{field_name} = users.id
                                            WHERE #{table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map{|r| [r.id, r.full_name]}.to_h rescue {}

      else
        values = object_type.find_by_sql("SELECT #{object_type.table_name}.id, #{object_type.table_name}.#{field_name} FROM #{object_type.table_name}
                                          WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                          .map{|r| [r.id, format_val(r.send(field_name.to_sym), field_type, field_param)]}.to_h rescue {}
      end

    end

    values
  end


  def get_data_table_for_google_visualization_sql(x_axis_field_arr:, records_ids:, query:)
    target = query.target
    x_axis_field_title = x_axis_field_arr[0][:title].nil? ? x_axis_field_arr[0][:label] : x_axis_field_arr[0][:title]
    data = [[x_axis_field_title, 'Count']]
    field = x_axis_field_arr[0]
    field_param = x_axis_field_arr[1]
    values = []

    if field.is_a?(Field)
      field_type = field.display_type
      fields_ids = Template.preload(:categories, :fields).where(id: query.templates).map(&:fields).flatten.select{|x| x.label == x_axis_field_title}.map(&:id)

      if target == 'Report'
        sr_records = Record.find_by_sql("SELECT records.id FROM records WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:id) rescue []

        values = RecordField.find_by_sql("SELECT record_fields.value FROM record_fields WHERE (record_fields.fields_id IN (#{fields_ids.join(',')})
                                              AND record_fields.records_id #{sr_records.present? ? "IN (#{sr_records.join(',')})" : "IS NULL"})")
                                              .map{|r| format_val(r.value, field_type, field_param) if r.value.present?} rescue []

      elsif target == 'Record'
        values = RecordField.find_by_sql("SELECT record_fields.value FROM record_fields WHERE record_fields.fields_id IN (#{fields_ids.join(',')}) AND
                                              record_fields.records_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                              .map{|r| format_val(r.value, field_type, field_param) if r.value.present?} rescue []

      elsif target == 'Submission'
        values = SubmissionField.find_by_sql("SELECT submission_fields.value FROM submission_fields WHERE submission_fields.fields_id IN (#{fields_ids.join(',')}) AND
                                                  submission_fields.submissions_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                                  .map{|r| format_val(r.value, field_type, field_param) if r.value.present?} rescue []

      end
    else
      field_type = field[:type]
      field_name = map_condition_field(target, field[:title])
      object_type = Object.const_get(target)

      case field_name
      when 'additional_info'
        if target == 'Report'
          sr_records = Report.find_by_sql("SELECT records.id FROM records WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:id) rescue []
          values = RecordField.find_by_sql("SELECT record_fields.value FROM record_fields INNER JOIN fields ON record_fields.fields_id = fields.id
                                            WHERE (record_fields.records_id #{sr_records.present? ? "IN (#{sr_records.join(',')})" : "IS NULL"} AND
                                            fields.additional_info = 1)").map(&:value) rescue []

        else
          values = RecordField.find_by_sql("SELECT record_fields.value FROM record_fields INNER JOIN fields ON record_fields.fields_id = fields.id
                                            WHERE (record_fields.records_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"} AND
                                            fields.additional_info = 1)").map(&:value) rescue []

        end

      when 'record_type'
        table_name = object_type.table_name
        values = Template.find_by_sql("SELECT templates.name FROM templates INNER JOIN #{table_name} ON #{table_name}.templates_id = templates.id
                                       WHERE #{table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:name) rescue []

      when 'included_reports'
        values = Record.find_by_sql("SELECT CONCAT(\'#\', records.id, \' (\', templates.name, \')\') AS inc_report FROM records INNER JOIN templates ON records.templates_id = templates.id
                                    WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:inc_report) rescue []

      when 'included_reports_types'
        values = Record.find_by_sql("SELECT templates.name FROM templates INNER JOIN records ON templates.id = records.templates_id
                                    WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:name) rescue []

      when 'included_occurrences', 'included_findings', 'source_of_input', 'meeting_host'
        temp_values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        temp_values.each do |temp_val|
          t_val = strip_html_tag(temp_val.send(field[:field].to_sym))
          if t_val.present? && field[:field].downcase.include?('get_source')
            t_val = t_val.split.first
          end
          t_val = format_val(t_val, field_type, field_param)
          values << t_val
        end

      when 'included_verifications'
        values = Verification.find_by_sql("SELECT CONCAT(verifications.status, \', \', verifications.verify_date) AS ver_status FROM verifications WHERE
                                          (verifications.owner_type = \'#{target}\' AND verifications.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})")
                                          .map(&:ver_status) rescue []

      when 'cause_label'
        values = Cause.find_by_sql("SELECT CONCAT(causes.category, \' > \', causes.attr) AS cause_label FROM causes WHERE
                                    (causes.owner_type = \'#{target}\' AND causes.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})").map(&:cause_label) rescue []

      when 'cause_value'
        values = Cause.find_by_sql("SELECT causes.value FROM causes WHERE (causes.owner_type = \'#{target}\'
                                    AND causes.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})")
                                    .map{|r| r.value.present? ? (['Audit', 'Inspection'].exclude?(query.target) ? (r.value == 1 ? 'Yes' : (r.value == 0 ? 'No' : r.value)) : r.value) : ""} rescue []

      when 'initial_risk_score'
        values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                          .map(&:get_risk_score) rescue []

      when 'mitigated_risk_score'
        values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                          .map(&:get_risk_score_after) rescue []

      when 'risk_severity', 'risk_severity_after', 'risk_likelihood', 'risk_likelihood_after'
        field_name = field_name.gsub('risk_', '')

        if field_name.include?('severity')
          arr = CONFIG::MATRIX_INFO[:severity_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
        else
          arr = CONFIG::MATRIX_INFO[:probability_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
        end

        temp_values = object_type.find_by_sql("SELECT #{object_type.table_name}.#{field_name} FROM #{object_type.table_name}
                                          WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        temp_values.each do |tv|
          values << arr[tv.send(field_name).to_i].gsub('&nbsp;', ' ') if tv.send(field_name).present?
        end

      when 'user_id'
        if CONFIG::GENERAL[:sabre_integration].present?
          values = User.find_by_sql("SELECT CONCAT(users.full_name, \' (\', users.employee_number, \')\') AS full_name FROM users INNER JOIN submissions ON submissions.user_id = users.id
                                    WHERE submissions.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:full_name) rescue []
        else
          values = User.find_by_sql("SELECT users.full_name FROM users INNER JOIN submissions ON submissions.user_id = users.id
                                    WHERE submissions.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:full_name) rescue []
        end

      when 'users_id'
        if CONFIG::GENERAL[:sabre_integration].present?
          values = User.find_by_sql("SELECT CONCAT(users.full_name, \' (\', users.employee_number, \')\') AS full_name FROM users INNER JOIN records ON records.users_id = users.id
                                    WHERE records.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:full_name) rescue []
        else
          values = User.find_by_sql("SELECT users.full_name FROM users INNER JOIN records ON records.users_id = users.id
                                    WHERE records.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:full_name) rescue []
        end

      when 'responsible_user_id', 'approver_id', 'created_by_id'
        table_name = object_type.table_name
        values = User.find_by_sql("SELECT users.full_name FROM users INNER JOIN #{table_name} ON #{table_name}.#{field_name} = users.id
                                   WHERE #{table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}").map(&:full_name) rescue []

      else
        values = object_type.find_by_sql("SELECT #{object_type.table_name}.#{field_name} FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                          .map(&field_name.to_sym).map{|val| format_val(val, field_type, field_param)} rescue []
      end

    end

    values.compact
          .flatten
          .reject(&:blank?)
          .inject(Hash.new(0)){|h, e| h[e] += 1; h}
          .sort_by{|k,v| k}
          .each{|pair| data << pair}

    data
  end


  def get_data_ids_table_for_google_visualization_sql(x_axis_field_arr:, records_ids:, query:)
    target = query.target
    x_axis_field_title = x_axis_field_arr[0][:title].nil? ? x_axis_field_arr[0][:label] : x_axis_field_arr[0][:title]
    data_ids = [[x_axis_field_title, 'IDs']]
    field = x_axis_field_arr[0]
    field_param = x_axis_field_arr[1]
    values = []
    val_hash = Hash.new { |hash, key| hash[key] = [] }

    if field.is_a?(Field)
      field_type = field.display_type
      fields_ids = Template.preload(:categories, :fields).where(id: query.templates).map(&:fields).flatten.select{|x| x.label == x_axis_field_title}.map(&:id)

      if target == 'Report'
        sr_records_map = Record.find_by_sql("SELECT records.id, records.reports_id FROM records WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                             .map{|r| [r.id, r.reports_id]}.to_h rescue {}

        values = RecordField.find_by_sql("SELECT record_fields.records_id, record_fields.value FROM record_fields WHERE (record_fields.fields_id IN (#{fields_ids.join(',')})
                                              AND record_fields.records_id #{sr_records_map.keys.present? ? "IN (#{sr_records_map.keys.join(',')})" : "IS NULL"})") rescue []

        values.each do |val|
          temp_val = format_val(val.value, field_type, field_param)
          if temp_val.class.name == 'Array'
            if temp_val.present?
              temp_val.each do |t_val|
                val_hash[t_val] << sr_records_map[val.records_id] if t_val.present? && sr_records_map[val.records_id].present?
              end
            end
          else
            val_hash[temp_val] << sr_records_map[val.records_id] if temp_val.present? && sr_records_map[val.records_id].present?
          end
        end

      elsif target == 'Record'
        values = RecordField.find_by_sql("SELECT record_fields.records_id, record_fields.value FROM record_fields WHERE record_fields.fields_id IN (#{fields_ids.join(',')}) AND
                                              record_fields.records_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          temp_val = format_val(val.value, field_type, field_param)
          if temp_val.class.name == 'Array'
            if temp_val.present?
              temp_val.each do |t_val|
                val_hash[t_val] << val.records_id if t_val.present?
              end
            end
          else
            val_hash[temp_val] << val.records_id if temp_val.present?
          end
        end

      elsif target == 'Submission'
        values = SubmissionField.find_by_sql("SELECT submission_fields.submissions_id, submission_fields.value FROM submission_fields WHERE submission_fields.fields_id IN (#{fields_ids.join(',')}) AND
                                                  submission_fields.submissions_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          temp_val = format_val(val.value, field_type, field_param)
          if temp_val.class.name == 'Array'
            if temp_val.present?
              temp_val.each do |t_val|
                val_hash[t_val] << val.submissions_id if t_val.present?
              end
            end
          else
            val_hash[temp_val] << val.submissions_id if temp_val.present?
          end
        end

      end
    else
      field_type = field[:type]
      field_name = map_condition_field(target, field[:title])
      object_type = Object.const_get(target)

      case field_name
      when 'additional_info'
        if target == 'Report'
          sr_records_map = Record.find_by_sql("SELECT records.id, records.reports_id FROM records WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}")
                                             .map{|r| [r.id, r.reports_id]}.to_h rescue {}

          values = RecordField.find_by_sql("SELECT record_fields.records_id, record_fields.value FROM record_fields INNER JOIN fields ON record_fields.fields_id = fields.id
                                            WHERE (record_fields.records_id #{sr_records_map.keys.present? ? "IN (#{sr_records_map.keys.join(',')})" : "IS NULL"} AND
                                            fields.additional_info = 1)") rescue []

          values.each do |val|
            val_hash[val.value] << sr_records_map[val.records_id] if val.value.present? && sr_records_map[val.records_id].present?
          end

        else
          values = RecordField.find_by_sql("SELECT record_fields.records_id, record_fields.value FROM record_fields INNER JOIN fields ON record_fields.fields_id = fields.id
                                            WHERE (record_fields.records_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"} AND
                                            fields.additional_info = 1)") rescue []

          values.each do |val|
            val_hash[val.value] << val.records_id if val.value.present?
          end

        end

      when 'record_type'
        table_name = object_type.table_name
        values = Template.find_by_sql("SELECT #{table_name}.id, templates.name FROM templates INNER JOIN #{table_name} ON #{table_name}.templates_id = templates.id
                                       WHERE #{table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          val_hash[val.name] << val.id if val.name.present?
        end

      when 'included_reports'
        values = Record.find_by_sql("SELECT records.reports_id, CONCAT(\'#\', records.id, \' (\', templates.name, \')\') AS inc_report FROM records INNER JOIN templates ON records.templates_id = templates.id
                                    WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          val_hash[val.inc_report] << val.reports_id if val.inc_report.present?
        end

      when 'included_reports_types'
        values = Record.find_by_sql("SELECT records.reports_id, templates.name FROM templates INNER JOIN records ON templates.id = records.templates_id
                                    WHERE records.reports_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          val_hash[val.name] << val.reports_id if val.name.present?
        end

      when 'included_occurrences', 'included_findings', 'source_of_input', 'meeting_host'
        values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          temp_val = strip_html_tag(val.send(field[:field]))
          if temp_val.present? && field[:field].downcase.include?('get_source')
            temp_val = temp_val.split.first
          end
          temp_val = format_val(temp_val, field_type, field_param)
          if temp_val.class.name == 'Array'
            if temp_val.present?
              temp_val.each do |t_val|
                val_hash[t_val] << val.id if t_val.present?
              end
            end
          else
            val_hash[temp_val] << val.id if temp_val.present?
          end
        end

      when 'included_verifications'
        values = Verification.find_by_sql("SELECT verifications.owner_id, CONCAT(verifications.status, \', \', verifications.verify_date) AS ver_status FROM verifications WHERE
                                          (verifications.owner_type = \'#{target}\' AND verifications.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})") rescue []

        values.each do |val|
          val_hash[val.ver_status] << val.owner_id if val.ver_status.present?
        end

      when 'cause_label'
        values = Cause.find_by_sql("SELECT causes.owner_id, CONCAT(causes.category, \' > \', causes.attr) AS cause_label FROM causes WHERE
                                    (causes.owner_type = \'#{target}\' AND causes.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})") rescue []

        values.each do |val|
          val_hash[val.cause_label] << val.owner_id if val.cause_label.present?
        end

      when 'cause_value'
        values = Cause.find_by_sql("SELECT causes.owner_id, causes.value FROM causes WHERE (causes.owner_type = \'#{target}\'
                                    AND causes.owner_id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"})") rescue []

        values.each do |val|
          temp_val = val.value.present? ? (['Audit', 'Inspection'].exclude?(query.target) ? (val.value == 1 ? 'Yes' : (val.value == 0 ? 'No' : val.value)) : val.value) : ""
          val_hash[temp_val] << val.owner_id if temp_val.present?
        end

      when 'initial_risk_score'
        values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          temp_val = val.send(:get_risk_score)
          val_hash[temp_val] << val.id if temp_val.present?
        end

      when 'mitigated_risk_score'
        values = object_type.find_by_sql("SELECT * FROM #{object_type.table_name} WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          temp_val = val.send(:get_risk_score_after)
          val_hash[temp_val] << val.id if temp_val.present?
        end

      when 'risk_severity', 'risk_severity_after', 'risk_likelihood', 'risk_likelihood_after'
        field_name = field_name.gsub('risk_', '')

        if field_name.include?('severity')
          arr = CONFIG::MATRIX_INFO[:severity_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
        else
          arr = CONFIG::MATRIX_INFO[:probability_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
        end

        values = object_type.find_by_sql("SELECT #{object_type.table_name}.id, #{object_type.table_name}.#{field_name} FROM #{object_type.table_name}
                                          WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          temp_val = val.send(field_name).present? ? arr[val.send(field_name).to_i].gsub('&nbsp;', ' ') : nil
          val_hash[temp_val] << val.id if temp_val.present?
        end

      when 'user_id'
        if CONFIG::GENERAL[:sabre_integration].present?
          values = User.find_by_sql("SELECT submissions.id, CONCAT(users.full_name, \' (\', users.employee_number, \')\') AS full_name FROM users INNER JOIN submissions ON submissions.user_id = users.id
                                    WHERE submissions.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []
        else
          values = User.find_by_sql("SELECT submissions.id, users.full_name FROM users INNER JOIN submissions ON submissions.user_id = users.id
                                    WHERE submissions.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []
        end

        values.each do |val|
          val_hash[val.full_name] << val.id if val.full_name.present?
        end

      when 'users_id'
        if CONFIG::GENERAL[:sabre_integration].present?
          values = User.find_by_sql("SELECT records.id, CONCAT(users.full_name, \' (\', users.employee_number, \')\') AS full_name FROM users INNER JOIN records ON records.users_id = users.id
                                     WHERE records.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []
        else
          values = User.find_by_sql("SELECT records.id, users.full_name FROM users INNER JOIN records ON records.users_id = users.id
                                     WHERE records.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []
        end

        values.each do |val|
          val_hash[val.full_name] << val.id if val.full_name.present?
        end

      when 'responsible_user_id', 'approver_id', 'created_by_id'
        table_name = object_type.table_name
        values = User.find_by_sql("SELECT users.full_name, #{table_name}.id FROM users INNER JOIN #{table_name} ON #{table_name}.#{field_name} = users.id
                                   WHERE #{table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          val_hash[val.full_name] << val.id if val.full_name.present?
        end

      else
        values = object_type.find_by_sql("SELECT #{object_type.table_name}.id, #{object_type.table_name}.#{field_name} FROM #{object_type.table_name}
                                          WHERE #{object_type.table_name}.id #{records_ids.present? ? "IN (#{records_ids.join(',')})" : "IS NULL"}") rescue []

        values.each do |val|
          temp_val = val.send(field_name.to_sym)
          temp_val = format_val(temp_val, field_type, field_param)
          if temp_val.class.name == 'Array'
            if temp_val.present?
              temp_val.each do |t_val|
                val_hash[t_val] << val.id if t_val.present?
              end
            end
          else
            val_hash[temp_val] << val.id if temp_val.present?
          end
        end

      end
    end

    val_hash = val_hash.sort_by{|k,v| k}
    val_hash.each do |k, v|
      data_ids << [k, v]
    end

    data_ids
  end
  # All methods above are for Query Visualizations Processing

  # All methods below are for Query Results Processing and a helper for both results and visualizations
  def get_query_results_ids(query)
    target_table = Object.const_get(query.target)
    target_table_name = target_table.table_name
    ids = []

    if query.query_conditions.present?
      cond_str = generate_ids_string(query, generate_parseable_string(query))
      cond_str.gsub!('AND', '&') if cond_str.include?('AND')
      cond_str.gsub!('OR', '|') if cond_str.include?('OR')
      ids = eval(cond_str)
    elsif ['Submission', 'Record'].include?(query.target)
      ids = target_table.find_by_sql("SELECT #{target_table_name}.id FROM #{target_table_name} WHERE
            #{target_table_name}.templates_id IN (#{query.templates.present? ? query.templates.join(',') : Template.find_by_sql("SELECT templates.id FROM templates").map(&:id).join(',')})
            #{query.target == 'Submission' ? " AND #{target_table_name}.completed = 1" : ""}").map(&:id)
    elsif query.target == 'Checklist'
      checklist_ids = checklist_custom_query(query, nil, nil)
      ids = target_table.find_by_sql("SELECT #{target_table_name}.id FROM #{target_table_name} WHERE
            #{target_table_name}.id #{checklist_ids.present? ? "IN (#{checklist_ids.join(',')})" : "IS NULL"}").map(&:id)
    else
      ids = target_table.find_by_sql("SELECT #{target_table_name}.id FROM #{target_table_name}").map(&:id)
    end

    ids.compact.uniq
  end


  def get_query_results(query)
    target_table = Object.const_get(query.target)
    records = target_table.find_by_sql(generate_query_string(query))
    records
  end


  def generate_query_string(query)
    target_table_name = Object.const_get(query.target).table_name
    sql = "SELECT #{target_table_name}.* FROM #{target_table_name} WHERE #{target_table_name}.id IS NOT NULL"
    sql = sql + " AND #{target_table_name}.completed = 1" if target_table_name == 'submissions'

    if query.query_conditions.present?
      cond_str = generate_ids_string(query, generate_parseable_string(query))
      cond_str.gsub!('AND', '&') if cond_str.include?('AND')
      cond_str.gsub!('OR', '|') if cond_str.include?('OR')
      ids = eval(cond_str).join(',')

      if ids.present?
        sql = sql + " AND id IN (#{ids})"
      else
        sql = "SELECT #{target_table_name}.* FROM #{target_table_name} WHERE #{target_table_name}.id IS NULL"
      end
    elsif ['Submission', 'Record'].include?(query.target)
      sql = sql + " AND #{target_table_name}.templates_id IN (#{query.templates.present? ? query.templates.join(',') : Template.find_by_sql("SELECT templates.id FROM templates").map(&:id).join(',')})"
    elsif query.target == 'Checklist'
      checklist_ids = checklist_custom_query(query, nil, nil)
      sql = sql + " AND #{target_table_name}.id #{checklist_ids.present? ? "IN (#{checklist_ids.join(',')})" : "IS NULL"}"
    end

    sql
  end


  def generate_parseable_string(query)
    query_arr = []
    query.query_conditions.each do |c|
      if c.query_conditions.present?
        element = generate_nested_string(c)
      else
        element = "C#{c.id}C"
      end
      query_arr << element
    end
    query_arr.join(' AND ')
  end


  def generate_nested_string(condition)
    "(#{condition.query_conditions.map{|cond| cond.operator.present? ? generate_nested_string(cond) : "C#{cond.id}C"}.join(" #{condition.operator} ")})"
  end


  def generate_ids_string(query, query_string)
    all_conditions = QueryCondition.where(id: query_string.scan(/\d+/).map(&:to_i))

    all_conditions.each do |c|
      to_replace = "C#{c.id}C"
      replace_with = c.field_name.present? ? generate_single_condition_ids(query, c) : nil
      replace_with = "[]" if !replace_with.present?
      query_string.gsub!(to_replace, replace_with)
    end

    return query_string
  end


  def generate_single_condition_ids(query, condition)
    field_name = map_condition_field(query.target, condition.field_name)

    if check_mapped_condition_field(query.target, field_name)
      generate_attribute_sql(query, condition)
    else
      generate_association_template_sql(query, condition)
    end
  end


  def generate_attribute_sql(query, condition)
    table_name = Object.const_get(query.target).table_name
    field_name = map_condition_field(query.target, condition.field_name)
    object_type = Object.const_get(query.target)
    search_value = condition.value.downcase.strip rescue ""
    str = ""

    target_field = object_type.get_meta_fields('show', 'index', 'invisible', 'query', 'close').keep_if{|x| x[:field].present? && x[:title] == condition.field_name}.first rescue nil

    if target_field.present?
      case condition.logic
      when "Equals To"
        case target_field[:type]
        when 'date','datetime'
          start_date = search_value.split("to")[0]
          end_date = search_value.split("to")[1] || search_value.split("to")[0]
          str = "DATE(#{table_name}.#{field_name}) >= \'#{start_date}\' AND DATE(#{table_name}.#{field_name}) <= \'#{end_date}\'"
        when 'boolean', 'boolean_box'
          search_value = search_value == 'yes' ? 1 : 0
          str = "#{table_name}.#{field_name} = #{search_value}"
        when 'checkbox'
          str = "LOWER(#{table_name}.#{field_name}) LIKE \'%#{search_value}%\'"
        when 'user'
          users = User.find_by_sql("SELECT users.id FROM users WHERE LOWER(users.full_name) = \'#{search_value}\'").map(&:id).join(',') rescue ""
          if users.present?
            str = "#{table_name}.#{field_name} IN (#{users})"
          else
            str = ""
          end
        else
          str = "LOWER(#{table_name}.#{field_name}) = \'#{search_value}\'"
        end

      when "Not Equal To"
        case target_field[:type]
        when 'date','datetime'
          start_date = search_value.split("to")[0]
          end_date = search_value.split("to")[1] || search_value.split("to")[0]
          str = "NOT (DATE(#{table_name}.#{field_name}) >= \'#{start_date}\' AND DATE(#{table_name}.#{field_name}) <= \'#{end_date}\')"
        when 'boolean', 'boolean_box'
          search_value = search_value == 'yes' ? 1 : 0
          str = "#{table_name}.#{field_name} <> #{search_value}"
        when 'checkbox'
          str = "LOWER(#{table_name}.#{field_name}) NOT LIKE \'%#{search_value}%\'"
        when 'user'
          users = User.find_by_sql("SELECT users.id FROM users WHERE LOWER(users.full_name) = \'#{search_value}\'").map(&:id).join(',') rescue ""
          if users.present?
            str = "#{table_name}.#{field_name} NOT IN (#{users})"
          else
            str = ""
          end
        else
          str = "LOWER(#{table_name}.#{field_name}) <> \'#{search_value}\'"
        end

      when "Contains"
        case target_field[:type]
        when 'date','datetime'
          dates = search_value.split("to")
          if dates.length > 1
            str = "DATE(#{table_name}.#{field_name}) >= \'#{dates[0]}\' AND DATE(#{table_name}.#{field_name}) <= \'#{dates[1]}\'"
          else
            str = "DATE(#{table_name}.#{field_name}) LIKE \'%#{dates[0]}%\'"
          end
        when 'boolean', 'boolean_box'
          search_value = search_value == 'yes' ? 1 : 0
          str = "#{table_name}.#{field_name} LIKE \'%#{search_value}%\'"
        when 'checkbox'
          str = "LOWER(#{table_name}.#{field_name}) LIKE \'%#{search_value}%\'"
        when 'user'
          users = User.find_by_sql("SELECT users.id FROM users WHERE LOWER(users.full_name) LIKE \'%#{search_value}%\'").map(&:id).join(',') rescue ""
          if users.present?
            str = "#{table_name}.#{field_name} IN (#{users})"
          else
            str = ""
          end
        else
          str = "LOWER(#{table_name}.#{field_name}) LIKE \'%#{search_value}%\'"
        end

      when "Does Not Contain"
        case target_field[:type]
        when 'date','datetime'
          dates = search_value.split("to")
          if dates.length > 1
            str = "NOT (DATE(#{table_name}.#{field_name}) >= \'#{dates[0]}\' AND DATE(#{table_name}.#{field_name}) <= \'#{dates[1]}\')"
          else
            str = "DATE(#{table_name}.#{field_name}) NOT LIKE \'%#{dates[0]}%\'"
          end
        when 'boolean', 'boolean_box'
          search_value = search_value == 'yes' ? 1 : 0
          str = "#{table_name}.#{field_name} NOT LIKE \'%#{search_value}%\'"
        when 'checkbox'
          str = "LOWER(#{table_name}.#{field_name}) NOT LIKE \'%#{search_value}%\'"
        when 'user'
          users = User.find_by_sql("SELECT users.id FROM users WHERE LOWER(users.full_name) LIKE \'%#{search_value}%\'").map(&:id).join(',') rescue ""
          if users.present?
            str = "#{table_name}.#{field_name} NOT IN (#{users})"
          else
            str = ""
          end
        else
          str = "LOWER(#{table_name}.#{field_name}) NOT LIKE \'%#{search_value}%\'"
        end

      when ">="
        case target_field[:type]
        when 'date','datetime'
          dates = search_value.split("to")
          if dates.length > 1
            str = "DATE(#{table_name}.#{field_name}) >= \'#{dates[1]}\'"
          else
            str = "DATE(#{table_name}.#{field_name}) >= \'#{dates[0]}\'"
          end
        else
          str = "#{table_name}.#{field_name} >= #{search_value}"
        end

      when "<"
        case target_field[:type]
        when 'date','datetime'
          dates = search_value.split("to")
          if dates.length > 1
            str = "DATE(#{table_name}.#{field_name}) <= \'#{dates[1]}\'"
          else
            str = "DATE(#{table_name}.#{field_name}) <= \'#{dates[0]}\'"
          end
        else
          str = "#{table_name}.#{field_name} < #{search_value}"
        end

      when 'Last ( ) Days'
        case target_field[:type]
        when 'date', 'datetime'
          start_date, end_date = (Date.current - search_value.to_f.days).strftime('%Y-%m-%d'), Date.today.strftime('%Y-%m-%d')
          str = "DATE(#{table_name}.#{field_name}) >= \'#{start_date}\' AND DATE(#{table_name}.#{field_name}) <= \'#{end_date}\'"
        end
      end
    end

    if str.present?
      case query.target
      when 'Submission'
        str = object_type.find_by_sql("SELECT #{table_name}.id FROM #{table_name} WHERE (#{str}
                AND #{table_name}.templates_id IN (#{query.templates.present? ? query.templates.join(',') : Template.find_by_sql("SELECT templates.id FROM templates").map(&:id).join(',')})
                AND #{table_name}.completed = 1)").map(&:id).to_s rescue []
      when 'Record'
        str = object_type.find_by_sql("SELECT #{table_name}.id FROM #{table_name} WHERE (#{str}
                AND #{table_name}.templates_id IN (#{query.templates.present? ? query.templates.join(',') : Template.find_by_sql("SELECT templates.id FROM templates").map(&:id).join(',')}))").map(&:id).to_s rescue []
      else
        str = object_type.find_by_sql("SELECT #{table_name}.id FROM #{table_name} WHERE #{str}").map(&:id).to_s rescue []
      end
    end

    str
  end


  def generate_association_template_sql(query, condition)
    object_type = Object.const_get(query.target)
    table_name = object_type.table_name
    field_name = map_condition_field(query.target, condition.field_name)
    search_value = condition.value.downcase.strip rescue ""
    ids = []
    comparison_string = "IS NULL"

    case condition.logic
    when 'Equals To'
      comparison_string = "= \'#{search_value}\'"
    when 'Not Equal To'
      comparison_string = "<> \'#{search_value}\'"
    when 'Contains'
      comparison_string = "LIKE \'%#{search_value}%\'"
    when 'Does Not Contain'
      comparison_string = "NOT LIKE \'%#{search_value}%\'"
    end

    case field_name
    when 'meeting_host' # All special cases like host and included findings etc
      case condition.logic
      when 'Equals To'
        ids = object_type.all.keep_if{|obj| obj.get_host.downcase == search_value}.map(&:id) rescue ""
      when 'Contains'
        ids = object_type.all.keep_if{|obj| obj.get_host.downcase.include?(search_value)}.map(&:id) rescue ""
      when 'Not Equal To'
        ids = object_type.all.keep_if{|obj| obj.get_host.downcase != search_value}.map(&:id) rescue ""
      when 'Does Not Contain'
        ids = object_type.all.keep_if{|obj| obj.get_host.downcase.exclude?(search_value)}.map(&:id) rescue ""
      end

    when 'additional_info'
      fields_ids = Field.find_by_sql("SELECT fields.id FROM fields INNER JOIN categories ON fields.categories_id = categories.id
                                        WHERE (categories.templates_id IN (#{query.templates.present? ? query.templates.join(',') : Template.find_by_sql("SELECT templates.id FROM templates").map(&:id).join(',')})
                                        AND fields.additional_info = 1)").map(&:id) rescue []
      ids = RecordField.find_by_sql("SELECT record_fields.records_id FROM record_fields WHERE (record_fields.fields_id IN (#{fields_ids}) AND LOWER(record_fields.value) #{comparison_string})").map(&:records_id) rescue ""

    when 'record_type'
      ids = object_type.find_by_sql("SELECT #{table_name}.id FROM #{table_name} INNER JOIN templates ON #{table_name}.templates_id = templates.id
                                    WHERE (#{table_name}.templates_id IN (#{query.templates.present? ? query.templates.join(',') : Template.find_by_sql("SELECT templates.id FROM templates").map(&:id).join(',')})
                                    AND LOWER(templates.name) #{comparison_string})").map(&:id) rescue ""

    when 'included_reports'
      ids = Record.find_by_sql("SELECT records.reports_id FROM records INNER JOIN templates ON records.templates_id = templates.id
                                WHERE (LOWER(templates.name) #{comparison_string} OR records.id #{comparison_string})").map(&:reports_id) rescue ""

    when 'included_reports_types'
      ids = Record.find_by_sql("SELECT records.reports_id FROM records INNER JOIN templates ON records.templates_id = templates.id WHERE
                                LOWER(templates.name) #{comparison_string}").map(&:reports_id) rescue ""

    when 'included_occurrences'
      if condition.field_name == "Full #{object_type.find_top_level_section.label}"
        case condition.logic
        when 'Equals To', 'Contains'
          ids = Occurrence.find_by_sql("SELECT occurrences.* FROM occurrences WHERE occurrences.owner_type=\'#{query.target}\'")
                                          .keep_if{|occurrence| occurrence.format_for_query.downcase.include?(search_value)}.map(&:owner_id) rescue ""
        when 'Not Equal To', 'Does Not Contain'
          ids = Occurrence.find_by_sql("SELECT occurrences.* FROM occurrences WHERE occurrences.owner_type=\'#{query.target}\'")
                                          .keep_if{|occurrence| occurrence.format_for_query.downcase.exclude?(search_value)}.map(&:owner_id) rescue ""
        end

      else
        ids = Occurrence.find_by_sql("SELECT occurrences.owner_id FROM occurrences WHERE (occurrences.owner_type=\'#{query.target}\' AND
                                                                  LOWER(occurrences.value) #{comparison_string})").map(&:owner_id) rescue ""
      end

    when 'included_verifications'
      ids = Verification.find_by_sql("SELECT verifications.owner_id FROM verifications WHERE (verifications.owner_type=\'#{query.target}\' AND
                                     LOWER(CONCAT(verifications.status, \', \', verifications.verify_date)) #{comparison_string})").map(&:owner_id) rescue ""

    when 'included_findings'
      case condition.logic
      when 'Equals To', 'Contains'
        ids = object_type.all.keep_if{|obj| obj.included_findings.downcase.include?(search_value)}.map(&:id) rescue ""
      when 'Not Equal To', 'Does Not Contain'
        ids = object_type.all.keep_if{|obj| obj.included_findings.downcase.exclude?(search_value)}.map(&:id) rescue ""
      end

    when 'source_of_input'
      case condition.logic
      when 'Equals To', 'Contains'
        ids = object_type.all.keep_if{|obj| obj.get_source.downcase.include?(search_value)}.map(&:id) rescue ""
      when 'Not Equal To', 'Does Not Contain'
        ids = object_type.all.keep_if{|obj| obj.get_source.downcase.exclude?(search_value)}.map(&:id) rescue ""
      end

    when 'cause_label'
      ids = Cause.find_by_sql("SELECT causes.owner_id FROM causes WHERE (causes.owner_type = \'#{query.target}\' AND LOWER(CONCAT(causes.category, \' > \', causes.attr)) #{comparison_string})").map(&:owner_id) rescue ""

    when 'cause_value'
      search_value = ['Audit', 'Inspection'].exclude?(query.target) ? (search_value == 'yes' ? 1 : (search_value == 'no' ? 0 : search_value)) : search_value
      ids = Cause.find_by_sql("SELECT causes.owner_id FROM causes WHERE (causes.owner_type = \'#{query.target}\' AND LOWER(causes.value) #{comparison_string})").map(&:owner_id) rescue ""

    when 'initial_risk_score'
      case condition.logic
      when 'Equals To', 'Contains'
        ids = object_type.all.keep_if{|obj| obj.get_risk_score.include?(search_value)}.map(&:id) rescue ""
      when 'Not Equal To', 'Does Not Contain'
        ids = object_type.all.keep_if{|obj| obj.get_risk_score.exclude?(search_value)}.map(&:id) rescue ""
      end

    when 'mitigated_risk_score'
      case condition.logic
      when 'Equals To', 'Contains'
        ids = object_type.all.keep_if{|obj| obj.get_risk_score_after.include?(search_value)}.map(&:id) rescue ""
      when 'Not Equal To', 'Does Not Contain'
        ids = object_type.all.keep_if{|obj| obj.get_risk_score_after.exclude?(search_value)}.map(&:id) rescue ""
      end

    when 'risk_severity', 'risk_severity_after', 'risk_likelihood', 'risk_likelihood_after'
      field_name = field_name.gsub('risk_', '')

      if field_name.include?('severity')
        arr = CONFIG::MATRIX_INFO[:severity_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
      else
        arr = CONFIG::MATRIX_INFO[:probability_table][:orientation] == :vertical ? CONFIG::MATRIX_INFO[:risk_table][:row_header] : CONFIG::MATRIX_INFO[:risk_table][:column_header]
      end

      arr = arr.map{|e| e.gsub('&nbsp;', ' ')}.map(&:downcase)
      ind = ['Equals To', 'Not Equal To'].include?(condition.logic) ? arr.index(search_value).to_s : arr.index{|a| a.include?(search_value)}
      ids = ""

      case condition.logic
      when 'Equals To', 'Contains'
        ids = object_type.find_by_sql("SELECT #{table_name}.id FROM #{table_name} WHERE #{table_name}.#{field_name} = \'#{ind}\'").map(&:id) rescue "" if ind.present?
      when 'Not Equal To', 'Does Not Contain'
        ids = object_type.find_by_sql("SELECT #{table_name}.id FROM #{table_name} WHERE #{table_name}.#{field_name} <> \'#{ind}\'").map(&:id) rescue "" if ind.present?
      end

    when 'checklist_get_owner', 'checklist_get_header', 'checklist_get_template'
      ids = checklist_custom_query(query, object_type, search_value, field_name)

    else
      if query.target != 'Checklist'
        # All Safety Reporting Template cases
        object_field_type = ['records', 'reports'].include?(table_name) ? Object.const_get('RecordField') : Object.const_get('SubmissionField')
        parent_id_attribute = ['records', 'reports'].include?(table_name) ? 'records_id' : 'submissions_id'
        object_field_table_name = object_field_type.table_name
        template_fields = Field.find_by_sql("SELECT fields.id, fields.data_type, fields.display_type, fields.nested_field_value
                                            FROM fields INNER JOIN categories ON categories.id=fields.categories_id WHERE categories.templates_id
                                            #{query.templates.present? ? "IN (#{query.templates.join(',')})" : "IS NULL"} AND fields.label=\'#{condition.field_name}\'") rescue nil

        if template_fields.present?
          template_fields.each do |template_field|
            str = ""
            case condition.logic
            when 'Equals To'
              case template_field.data_type
              when 'datetime', 'date'
                start_date = search_value.split("to")[0]
                end_date = search_value.split("to")[1] || search_value.split("to")[0]
                str = "DATE(#{object_field_table_name}.value) >= \'#{start_date}\' AND DATE(#{object_field_table_name}.value) <= \'#{end_date}\'"
              else
                case template_field.display_type
                when 'employee'
                  if CONFIG::GENERAL[:sabre_integration].present?
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.employee_number) = \'#{search_value}\'").map(&:id).map(&:to_s) |
                    User.find_by_sql("SELECT LOWER(users.employee_number) FROM users WHERE LOWER(users.employee_number) = \'#{search_value}\'").map(&:employee_number).map(&:to_s)) rescue nil
                  else
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.full_name) = \'#{search_value}\'").map(&:id).map(&:to_s) |
                    User.where("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name?) = \'#{search_value}\'").map(&:full_name).map(&:to_s)) rescue nil
                  end

                  if matching_users.present?
                    str = "LOWER(#{object_field_table_name}.value) IN (\'#{matching_users.join(',')}\')"
                  else
                    str = ""
                  end
                else
                  str = "LOWER(TRIM(#{object_field_table_name}.value)) = \'#{search_value}\'"
                end
              end

            when 'Not Equal To'
              case template_field.data_type
              when 'datetime', 'date'
                start_date = search_value.split("to")[0]
                end_date = search_value.split("to")[1] || search_value.split("to")[0]
                str = "NOT (DATE(#{object_field_table_name}.value) >= \'#{start_date}\' AND DATE(#{object_field_table_name}.value) <= \'#{end_date}\')"
              else
                case template_field.display_type
                when 'employee'
                  if CONFIG::GENERAL[:sabre_integration].present?
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.employee_number) = \'#{search_value}\'").map(&:id).map(&:to_s) |
                    User.find_by_sql("SELECT LOWER(users.employee_number) FROM users WHERE LOWER(users.employee_number) = \'#{search_value}\'").map(&:employee_number).map(&:to_s)) rescue nil
                  else
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.full_name) = \'#{search_value}\'").map(&:id).map(&:to_s) |
                    User.where("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name) = \'#{search_value}\'").map(&:full_name).map(&:to_s)) rescue nil
                  end

                  if matching_users.present?
                    str = "LOWER(#{object_field_table_name}.value) NOT IN (\'#{matching_users.join(',')}\')"
                  else
                    str = ""
                  end
                else
                  str = "LOWER(TRIM(#{object_field_table_name}.value)) <> \'#{search_value}\'"
                end
              end

            when 'Contains'
              case template_field.data_type
              when 'datetime', 'date'
                start_date = search_value.split("to")[0]
                end_date = search_value.split("to")[1] || search_value.split("to")[0]
                str = "DATE(#{object_field_table_name}.value) >= \'#{start_date}\' AND DATE(#{object_field_table_name}.value) <= \'#{end_date}\'"
              else
                case template_field.display_type
                when 'employee'
                  if CONFIG::GENERAL[:sabre_integration].present?
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.employee_number) LIKE \'%#{search_value}%\'").map(&:id).map(&:to_s) |
                    User.find_by_sql("SELECT LOWER(users.employee_number) FROM users WHERE LOWER(users.employee_number) LIKE \'%#{search_value}%\'").map(&:employee_number).map(&:to_s)) rescue nil
                  else
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.full_name) LIKE \'%#{search_value}%\'").map(&:id).map(&:to_s) |
                    User.where("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name) LIKE \'%#{search_value}%\'").map(&:full_name).map(&:to_s)) rescue nil
                  end

                  if matching_users.present?
                    str = "LOWER(#{object_field_table_name}.value) REGEXP \'#{matching_users.join('|')}\'"
                  else
                    str = ""
                  end
                else
                  str = "LOWER(TRIM(#{object_field_table_name}.value)) LIKE \'%#{search_value}%\'"
                end
              end

            when 'Does Not Contain'
              case template_field.data_type
              when 'datetime', 'date'
                start_date = search_value.split("to")[0]
                end_date = search_value.split("to")[1] || search_value.split("to")[0]
                str = "NOT (DATE(#{object_field_table_name}.value) >= \'#{start_date}\' AND DATE(#{object_field_table_name}.value) <= \'#{end_date}\')"
              else
                case template_field.display_type
                when 'employee'
                  if CONFIG::GENERAL[:sabre_integration].present?
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.employee_number) LIKE \'%#{search_value}%\'").map(&:id).map(&:to_s) |
                    User.find_by_sql("SELECT LOWER(users.employee_number) FROM users WHERE LOWER(users.employee_number) LIKE \'%#{search_value}%\'").map(&:employee_number).map(&:to_s)) rescue nil
                  else
                    matching_users = (User.where("SELECT users.id FROM users WHERE LOWER(users.full_name) LIKE \'%#{search_value}%\'").map(&:id).map(&:to_s) |
                    User.where("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name) LIKE \'%#{search_value}%\'").map(&:full_name).map(&:to_s)) rescue nil
                  end

                  if matching_users.present?
                    str = "LOWER(#{object_field_table_name}.value) NOT REGEXP \'#{matching_users.join('|')}\'"
                  else
                    str = ""
                  end
                else
                  str = "LOWER(TRIM(#{object_field_table_name}.value)) NOT LIKE \'%#{search_value}%\'"
                end
              end

            when '>='
              case template_field.data_type
              when 'date', 'datetime'
                dates = search_value.split("to")
                if dates.length > 1
                  start_date = dates[0]
                  end_date = dates[1]
                  str = "DATE(#{object_field_table_name}.value) >= \'#{dates[1]}\'"
                else
                  date = dates[0]
                  str = "DATE(#{object_field_table_name}.value) >= \'#{dates[0]}\'"
                end
              else
                str = "#{object_field_table_name}.value >= #{search_value}"
              end

            when '<'
              case template_field.data_type
              when 'date', 'datetime'
                dates = search_value.split("to")
                if dates.length > 1
                  start_date = dates[0]
                  end_date = dates[1]
                  str = "DATE(#{object_field_table_name}.value) <= \'#{dates[1]}\'"
                else
                  date = dates[0]
                  str = "DATE(#{object_field_table_name}.value) <= \'#{dates[0]}\'"
                end
              else
                str = "#{object_field_table_name}.value < #{search_value}"
              end

            when 'Last ( ) Days'
              case template_field.data_type
              when 'date', 'datetime'
                start_date, end_date = (Date.current - search_value.to_f.days).strftime('%Y-%m-%d'), Date.today.strftime('%Y-%m-%d')
                str = "DATE(#{object_field_table_name}.value) >= \'#{start_date}\' AND DATE(#{object_field_table_name}.value) <= \'#{end_date}\'"
              end
            end

            if str.present?
              if query.target == 'Report'
                temp_ids = object_field_type.find_by_sql("SELECT #{object_field_table_name}.#{parent_id_attribute} FROM #{object_field_table_name} WHERE #{str} AND #{object_field_table_name}.fields_id=#{template_field.id}").map(&parent_id_attribute.to_sym) rescue []
                str = Record.find_by_sql("SELECT records.reports_id FROM records WHERE records.id #{temp_ids.present? ? "IN (#{temp_ids.join(',')})" : "IS NULL"}").map(&:reports_id) rescue []
              elsif query.target == 'Submission'
                temp_ids = object_field_type.find_by_sql("SELECT #{object_field_table_name}.#{parent_id_attribute} FROM #{object_field_table_name} WHERE #{str} AND #{object_field_table_name}.fields_id=#{template_field.id}").map(&parent_id_attribute.to_sym) rescue []
                str = Submission.find_by_sql("SELECT submissions.id FROM submissions WHERE submissions.id #{temp_ids.present? ? "IN (#{temp_ids.join(',')})" : "IS NULL"} AND submissions.completed = 1").map(&:id) rescue []
              else
                str = object_field_type.find_by_sql("SELECT #{object_field_table_name}.#{parent_id_attribute} FROM #{object_field_table_name} WHERE #{str} AND #{object_field_table_name}.fields_id=#{template_field.id}").map(&parent_id_attribute.to_sym) rescue []
              end
              ids = ids | str
            end

          end
        else
          ids = ""
        end
      else
        #All checklist template cases
        ids = generate_checklist_sql(query, condition)
      end
    end

    ids.to_s
  end


  def checklist_custom_query(query, search_value, field_name)
    checklist_ids = ""

    if query.templates.present?
      if query.templates.include?('-1')
        templates_ids = query.templates.clone.reject(&:blank?)
        templates_ids.delete('-1')
        if templates_ids.present?
          checklist_ids = Checklist.find_by_sql("SELECT checklists.id FROM checklists WHERE (checklists.owner_type <> \'ChecklistHeader\' AND (checklists.template_id IN (#{templates_ids.join(',')}) OR checklists.template_id IS NULL))").map(&:id) rescue ""
        else
          checklist_ids = Checklist.find_by_sql("SELECT checklists.id FROM checklists WHERE (checklists.owner_type <> \'ChecklistHeader\' AND checklists.template_id IS NULL)").map(&:id) rescue ""
        end
      else
        checklist_ids = Checklist.find_by_sql("SELECT checklists.id FROM checklists WHERE (checklists.owner_type <> \'ChecklistHeader\' AND checklists.template_id IN (#{query.templates.join(',')}))").map(&:id) rescue ""
      end
    else
      checklist_ids = Checklist.find_by_sql("SELECT checklists.id FROM checklists WHERE checklists.owner_type <> \'ChecklistHeader\'").map(&:id) rescue ""
    end

    if checklist_ids.present? && field_name.present?
      field_name.gsub!('checklist_', '')
      case condition.logic
      when 'Equals To', 'Contains'
        ids = Checklist.where(id: checklist_ids).keep_if{|obj| obj.send(field_name).include?(search_value)}.map(&:id) rescue ""
      when 'Not Equal To', 'Does Not Contain'
        ids = Checklist.where(id: checklist_ids).keep_if{|obj| obj.send(field_name).exclude?(search_value)}.map(&:id) rescue ""
      end
    end

    checklist_ids
  end


  def generate_checklist_sql(query, condition)
    field_name = condition.field_name
    search_value = condition.value.downcase rescue ""
    checklists = nil
    valid_rows = []

    if query.templates.present?
      if query.templates.include?('-1')
        templates_ids = query.templates.clone.reject(&:blank?)
        templates_id.delete('-1')
        checklists = Checklist.preload(:checklist_rows => :checklist_cells).find_by_sql("SELECT checklists.id FROM checklists
          WHERE (checklists.owner_type <> \'ChecklistHeader\' AND checklists.template_id IN (#{templates_ids.join(',')} AND checklists.template_id IS NULL))")
      else
        checklists = Checklist.preload(:checklist_rows => :checklist_cells).find_by_sql("SELECT checklists.id FROM checklists
          WHERE (checklists.owner_type <> \'ChecklistHeader\' AND checklists.template_id IN (#{query.templates.join(',')}))")
      end
    else
      checklists = Checklist.preload(:checklist_rows => :checklist_cells).where("owner_type != ?", "ChecklistHeader")
    end


    if checklists.present?
      checklists_rows = checklists.map(&:checklist_rows).flatten
      headers = ChecklistHeaderItem.find_by_sql("SELECT checklist_header_items.* FROM checklist_header_items WHERE checklist_header_items.title = \'#{condition.field_name}\'")

      if checklists_rows.present?
        checklists_rows.flatten.each do |checklist_row|
          cells = checklist_row
                  .checklist_cells.flatten
                  .select { |cell| headers.map(&:id).include? cell.checklist_header_item_id }

          case condition.logic
          when 'Equals To'
            case cells.map(&:data_type).first
            when 'employee'
              # values = cells.map(&:value).compact.map(&:downcase).map{ |val| User.find(val).full_name rescue '' }.first.downcase
              values = User.find_by_sql("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name)
                                        REGEXP \'#{cells.map(&:value).compact.map(&:downcase).map(&:strip).join('|')}\'").map(&:full_name).first rescue nil
              valid_rows << checklist_row if values == search_value
            else
              values = cells.map(&:value).compact.map(&:downcase).map(&:strip)
              valid_rows << checklist_row if values.include?(search_value.strip)
            end

          when 'Not Equal To'
            case cells.map(&:data_type).first
            when 'employee'
              values = User.find_by_sql("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name)
                                        REGEXP \'#{cells.map(&:value).compact.map(&:downcase).map(&:strip).join('|')}\'").map(&:full_name).first rescue nil
              valid_rows << checklist_row if values != search_value
            else
              values = cells.map(&:value).compact.map(&:downcase).map(&:strip)
              valid_rows << checklist_row if values.exclude?(search_value.strip)
            end

          when 'Contains'
            case cells.map(&:data_type).first
            when 'employee'
              values = User.find_by_sql("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name)
                                        REGEXP \'#{cells.map(&:value).compact.map(&:downcase).join('|')}\'").map(&:full_name).first rescue nil
              valid_rows << checklist_row if values.present? && values.include?(search_value)
            else
              values = cells.map(&:value).compact.map(&:downcase)

              values.each do |value|
                if value.include?(search_value)
                  valid_rows << checklist_row
                  break
                end
              end
            end

          when 'Does Not Contain'
            case cells.map(&:data_type).first
            when 'employee'
              values = User.find_by_sql("SELECT LOWER(users.full_name) FROM users WHERE LOWER(users.full_name)
                                        REGEXP \'#{cells.map(&:value).compact.map(&:downcase).join('|')}\'").map(&:full_name).first rescue nil
              valid_rows << checklist_row if values.present? && values.exclude?(search_value)
            else
              values = cells.map(&:value).compact.map(&:downcase)

              values.each do |value|
                if value.exclude?(search_value)
                  valid_rows << checklist_row
                  break
                end
              end
            end

          when '>='
            values = cells.map(&:value).compact.map(&:downcase)
            case cells.map(&:data_type).first
            when 'date'
              values.each do |value|
                found = value.to_date >= search_value.to_date rescue false
                if found
                  valid_rows << checklist_row
                  break
                end
              end
            when 'datetime'
              values.each do |value|
                found = value.to_datetime >= search_value.to_datetime rescue false
                if found
                  valid_rows << checklist_row
                  break
                end
              end
            else
              values.each do |value|
                found = value.to_f >= search_value.to_f rescue false
                if found
                  valid_rows << checklist_row
                  break
                end
              end
            end

          when '<'
            values = cells.map(&:value).compact.map(&:downcase)
            case cells.map(&:data_type).first
            when 'date'
              values.each do |value|
                found = value.to_date <= search_value.to_date rescue false
                if found
                  valid_rows << checklist_row
                  break
                end
              end
            when 'datetime'
              values.each do |value|
                found = value.to_datetime <= search_value.to_datetime rescue false
                if found
                  valid_rows << checklist_row
                  break
                end
              end
            else
              values.each do |value|
                found = value.to_f < search_value.to_f rescue false
                if found
                  valid_rows << checklist_row
                  break
                end
              end
            end

          end
        end
      end
    end

    if valid_rows.present?
      valid_rows.map(&:checklist_id).uniq
    else
      ""
    end
  end


  def map_condition_field(target, condition_field)
    object_type = Object.const_get(target)

    mapping_hash = Hash.new

    mapping_hash['Submission'] = Hash.new
    mapping_hash['Submission']['Submitted By'] = 'user_id'
    mapping_hash['Submission']['Event Date/Time'] = 'event_date'
    mapping_hash['Submission']['Event Title'] = 'description'
    mapping_hash['Submission']['Submission Type'] = 'record_type'


    mapping_hash['Record'] = Hash.new
    mapping_hash['Record']['Submitted By'] = 'users_id'
    mapping_hash['Record']['Accepted Into ASAP'] = 'asap'
    mapping_hash['Record']["#{Record.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Record']["Full #{Record.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Record']["EIR Number"] = 'eir'
    mapping_hash['Record']['Event Date/Time'] = 'event_date'
    mapping_hash['Record']['Event Title'] = 'description'
    mapping_hash['Record']['Exclude From ASAP Library'] = 'scoreboard'
    mapping_hash['Record']["#{I18n.t('sr.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['Record']["#{I18n.t('sr.risk.mitigated.title')} Risk"] = 'risk_factor_after'
    mapping_hash['Record']["#{I18n.t('sa.risk.baseline.title')} Severity"] = 'risk_severity'
    mapping_hash['Record']["#{I18n.t('sa.risk.mitigated.title')} Severity"] = 'risk_severity_after'
    mapping_hash['Record']["#{I18n.t('sa.risk.baseline.title')} Likelihood"] = 'risk_likelihood'
    mapping_hash['Record']["#{I18n.t('sa.risk.mitigated.title')} Likelihood"] = 'risk_likelihood_after'
    mapping_hash['Record']['Sole Source'] = 'sole'
    mapping_hash['Record']["Additional Info"] = 'additional_info'
    mapping_hash['Record']["Type"] = 'record_type'


    mapping_hash['Report'] = Hash.new
    mapping_hash['Report']['Accepted Into ASAP'] = 'asap'
    mapping_hash['Report']["#{Report.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Report']["Full #{Report.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Report']['Event Date'] = 'event_date'
    mapping_hash['Report']['Event Title'] = 'name'
    mapping_hash['Report']['Event Description'] = 'narrative'
    mapping_hash['Report']["#{I18n.t('sr.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['Report']["#{I18n.t('sr.risk.mitigated.title')} Risk"] = 'risk_factor_after'
    mapping_hash['Report']["#{I18n.t('sa.risk.baseline.title')} Severity"] = 'risk_severity'
    mapping_hash['Report']["#{I18n.t('sa.risk.mitigated.title')} Severity"] = 'risk_severity_after'
    mapping_hash['Report']["#{I18n.t('sa.risk.baseline.title')} Likelihood"] = 'risk_likelihood'
    mapping_hash['Report']["#{I18n.t('sa.risk.mitigated.title')} Likelihood"] = 'risk_likelihood_after'
    mapping_hash['Report']['Meeting Minutes'] = 'minutes'
    mapping_hash['Report']["Included Reports"] = 'included_reports'
    mapping_hash['Report']["Included Reports Types"] = 'included_reports_types'


    mapping_hash['CorrectiveAction'] = Hash.new
    mapping_hash['CorrectiveAction']['Creator'] = 'created_by_id'
    mapping_hash['CorrectiveAction']['Is this only a recommendation'] = 'recommendation'
    mapping_hash['CorrectiveAction']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['CorrectiveAction']['Actual Completion Date'] = 'close_date'
    mapping_hash['CorrectiveAction']['Date Opened'] = 'opened_date'
    mapping_hash['CorrectiveAction']['Date Assigned'] = 'assigned_date'
    mapping_hash['CorrectiveAction']['Date Completed/Rejected'] = 'decision_date'
    mapping_hash['CorrectiveAction']['Responsible User'] = 'responsible_user_id'
    mapping_hash['CorrectiveAction']['Final Approver'] = 'approver_id'
    mapping_hash['CorrectiveAction']['Company Corrective Action'] = 'company'
    mapping_hash['CorrectiveAction']['Employee Corrective Action'] = 'employee'
    mapping_hash['CorrectiveAction']['Immediate Action'] = 'bimmediate_action'
    mapping_hash['CorrectiveAction']['Immediate Action Detail'] = 'immediate_action'
    mapping_hash['CorrectiveAction']['Comprehensive Action'] = 'bcomprehensive_action'
    mapping_hash['CorrectiveAction']['Comprehensive Action Detail'] = 'comprehensive_action'
    mapping_hash['CorrectiveAction']['Responsible User\'s Comments'] = 'corrective_actions_comment'
    mapping_hash['CorrectiveAction']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['CorrectiveAction']["Verifications"] = 'included_verifications'


    mapping_hash['Audit'] = Hash.new
    mapping_hash['Audit']['Creator'] = 'created_by_id'
    mapping_hash['Audit']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['Audit']['Actual Completion Date'] = 'close_date'
    mapping_hash['Audit']['Auditor'] = 'responsible_user_id'
    mapping_hash['Audit']['Final Approver'] = 'approver_id'
    mapping_hash['Audit']['Auditing Department'] = 'department'
    mapping_hash['Audit']['Department being Audited'] = 'audit_department'
    mapping_hash['Audit']['Internal/External/Supplier'] = 'supplier'
    mapping_hash['Audit']['Objective and Scope'] = 'objective'
    mapping_hash['Audit']['References and Requirements'] = 'reference'
    mapping_hash['Audit']['Audit Instructions'] = 'instruction'
    mapping_hash['Audit']['Auditor\'s Comments'] = 'comment'
    mapping_hash['Audit']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['Audit']['Included Findings'] = 'included_findings'
    mapping_hash['Audit']["#{CONFIG::CAUSE_LABEL} Label"] = 'cause_label'
    mapping_hash['Audit']["#{CONFIG::CAUSE_LABEL} Value"] = 'cause_value'
    mapping_hash['Audit']["Verifications"] = 'included_verifications'


    mapping_hash['Inspection'] = Hash.new
    mapping_hash['Inspection']['Creator'] = 'created_by_id'
    mapping_hash['Inspection']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['Inspection']['Actual Completion Date'] = 'close_date'
    mapping_hash['Inspection']['Lead Inspector'] = 'responsible_user_id'
    mapping_hash['Inspection']['Final Approver'] = 'approver_id'
    mapping_hash['Inspection']['Inspection Department'] = 'department'
    mapping_hash['Inspection']['Department being Inspected'] = 'inspection_department'
    mapping_hash['Inspection']['Type'] = 'inspection_type'
    mapping_hash['Inspection']['Internal/External/Supplier'] = 'supplier'
    mapping_hash['Inspection']['Objective and Scope'] = 'objective'
    mapping_hash['Inspection']['References and Requirements'] = 'reference'
    mapping_hash['Inspection']['Inspection Instructions'] = 'instruction'
    mapping_hash['Inspection']['Lead Inspector\'s Comments'] = 'comment'
    mapping_hash['Inspection']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['Inspection']['Included Findings'] = 'included_findings'
    mapping_hash['Inspection']["#{CONFIG::CAUSE_LABEL} Label"] = 'cause_label'
    mapping_hash['Inspection']["#{CONFIG::CAUSE_LABEL} Value"] = 'cause_value'
    mapping_hash['Inspection']["Verifications"] = 'included_verifications'


    mapping_hash['Evaluation'] = Hash.new
    mapping_hash['Evaluation']['Creator'] = 'created_by_id'
    mapping_hash['Evaluation']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['Evaluation']['Actual Completion Date'] = 'close_date'
    mapping_hash['Evaluation']['Lead Evaluator'] = 'responsible_user_id'
    mapping_hash['Evaluation']['Final Approver'] = 'approver_id'
    mapping_hash['Evaluation']['Evaluation Department'] = 'department'
    mapping_hash['Evaluation']['Department being Inspected'] = 'evaluation_department'
    mapping_hash['Evaluation']['Type'] = 'evaluation_type'
    mapping_hash['Evaluation']['Internal/External/Supplier'] = 'supplier'
    mapping_hash['Evaluation']['Objective and Scope'] = 'objective'
    mapping_hash['Evaluation']['References and Requirements'] = 'reference'
    mapping_hash['Evaluation']['Evaluation Instructions'] = 'instruction'
    mapping_hash['Evaluation']['Lead Evaluator\'s Comments'] = 'comment'
    mapping_hash['Evaluation']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['Evaluation']['Included Findings'] = 'included_findings'
    mapping_hash['Evaluation']["Verifications"] = 'included_verifications'


    mapping_hash['Investigation'] = Hash.new
    mapping_hash['Investigation']['Creator'] = 'created_by_id'
    mapping_hash['Investigation']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['Investigation']['Actual Completion Date'] = 'close_date'
    mapping_hash['Investigation']['Investigator'] = 'responsible_user_id'
    mapping_hash['Investigation']['Final Approver'] = 'approver_id'
    mapping_hash['Investigation']['Date/Time When Event Occurred'] = 'event_occured'
    mapping_hash['Investigation']['Local Time When Event Occurred'] = 'local_event_occured'
    mapping_hash['Investigation']['Investigation Type'] = 'inv_type'
    mapping_hash['Investigation']['Regulatory Violation'] = 'ntsb' # SCX modification
    mapping_hash['Investigation']['NTSB Reportable'] = 'ntsb'
    mapping_hash['Investigation']['Description of Event'] = 'description'
    mapping_hash['Investigation']['Investigator\'s Comments'] = 'investigator_comment'
    mapping_hash['Investigation']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['Investigation']["#{Investigation.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Investigation']["Full #{Investigation.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Investigation']["#{I18n.t('sa.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['Investigation']["#{I18n.t('sa.risk.mitigated.title')} Risk"] = 'risk_factor_after'
    mapping_hash['Investigation']["#{I18n.t('sa.risk.baseline.title')} Severity"] = 'risk_severity'
    mapping_hash['Investigation']["#{I18n.t('sa.risk.mitigated.title')} Severity"] = 'risk_severity_after'
    mapping_hash['Investigation']["#{I18n.t('sa.risk.baseline.title')} Likelihood"] = 'risk_likelihood'
    mapping_hash['Investigation']["#{I18n.t('sa.risk.mitigated.title')} Likelihood"] = 'risk_likelihood_after'
    mapping_hash['Investigation']['Source of Input'] = 'source_of_input'
    mapping_hash['Investigation']['Included Findings'] = 'included_findings'
    mapping_hash['Investigation']["Verifications"] = 'included_verifications'


    mapping_hash['Finding'] = Hash.new
    mapping_hash['Finding']['Creator'] = 'created_by_id'
    mapping_hash['Finding']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['Finding']['Actual Completion Date'] = 'close_date'
    mapping_hash['Finding']['Responsible User'] = 'responsible_user_id'
    mapping_hash['Finding']['Final Approver'] = 'approver_id'
    mapping_hash['Finding']['Reference or Requirement'] = 'reference'
    mapping_hash['Finding']['Safety Hazard'] = 'safety'
    mapping_hash['Finding']['Repeat Finding'] = 'repeat'
    mapping_hash['Finding']['Procedure'] = 'procedures'
    mapping_hash['Finding']['Immediate Action Required'] = 'immediate_action'
    mapping_hash['Finding']['Immediate Action Taken'] = 'action_taken'
    mapping_hash['Finding']['Description of Finding'] = 'description'
    mapping_hash['Finding']['Analysis Results'] = 'analysis_result'
    mapping_hash['Finding']['Responsible User\'s Comments'] = 'findings_comment'
    mapping_hash['Finding']['Other'] = 'other'
    mapping_hash['Finding']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['Finding']["#{Finding.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Finding']["Full #{Finding.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Finding']["#{I18n.t('sa.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['Finding']["#{I18n.t('sa.risk.mitigated.title')} Risk"] = 'risk_factor_after'
    mapping_hash['Finding']["#{I18n.t('sa.risk.baseline.title')} Severity"] = 'risk_severity'
    mapping_hash['Finding']["#{I18n.t('sa.risk.mitigated.title')} Severity"] = 'risk_severity_after'
    mapping_hash['Finding']["#{I18n.t('sa.risk.baseline.title')} Likelihood"] = 'risk_likelihood'
    mapping_hash['Finding']["#{I18n.t('sa.risk.mitigated.title')} Likelihood"] = 'risk_likelihood_after'
    mapping_hash['Finding']['Source of Input'] = 'source_of_input'
    mapping_hash['Finding']["Verifications"] = 'included_verifications'


    mapping_hash['SmsAction'] = Hash.new
    mapping_hash['SmsAction']['Creator'] = 'created_by_id'
    mapping_hash['SmsAction']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['SmsAction']['Actual Completion Date'] = 'close_date'
    mapping_hash['SmsAction']['Responsible User'] = 'responsible_user_id'
    mapping_hash['SmsAction']['Final Approver'] = 'approver_id'
    mapping_hash['SmsAction']['Employee Corrective Action'] = 'emp'
    mapping_hash['SmsAction']['Company Corrective Action'] = 'dep'
    mapping_hash['SmsAction']['Description of Corrective Action'] = 'description'
    mapping_hash['SmsAction']['Responsible User\'s Comments'] = 'corrective_actions_comment'
    mapping_hash['SmsAction']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['SmsAction']["#{I18n.t('sa.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['SmsAction']["#{I18n.t('sa.risk.mitigated.title')} Risk"] = 'risk_factor_after'
    mapping_hash['SmsAction']["#{I18n.t('sa.risk.baseline.title')} Severity"] = 'risk_severity'
    mapping_hash['SmsAction']["#{I18n.t('sa.risk.mitigated.title')} Severity"] = 'risk_severity_after'
    mapping_hash['SmsAction']["#{I18n.t('sa.risk.baseline.title')} Likelihood"] = 'risk_likelihood'
    mapping_hash['SmsAction']["#{I18n.t('sa.risk.mitigated.title')} Likelihood"] = 'risk_likelihood_after'
    mapping_hash['SmsAction']['Source of Input'] = 'source_of_input'
    mapping_hash['SmsAction']["Verifications"] = 'included_verifications'


    mapping_hash['Recommendation'] = Hash.new
    mapping_hash['Recommendation']['Creator'] = 'created_by_id'
    mapping_hash['Recommendation']['Scheduled Response Date'] = 'due_date'
    mapping_hash['Recommendation']['Actual Response Date'] = 'close_date'
    mapping_hash['Recommendation']['Responsible User'] = 'responsible_user_id'
    mapping_hash['Recommendation']['Final Approver'] = 'approver_id'
    mapping_hash['Recommendation']['Responsible Department'] = 'department'
    mapping_hash['Recommendation']['Immediate Action Required'] = 'immediate_action'
    mapping_hash['Recommendation']['Action'] = 'recommended_action'
    mapping_hash['Recommendation']['Description of Recommendation'] = 'description'
    mapping_hash['Recommendation']['Responsible User\'s Comments'] = 'recommendations_comment'
    mapping_hash['Recommendation']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['Recommendation']['Source of Input'] = 'source_of_input'
    mapping_hash['Recommendation']["Verifications"] = 'included_verifications'


    mapping_hash['Sra'] = Hash.new
    mapping_hash['Sra']['SRM Triggers'] = 'type_of_change' # AJT modification
    mapping_hash['Sra']['SRA Title'] = 'title'
    mapping_hash['Sra']['System/Task'] = 'system_task'
    mapping_hash['Sra']['Creator'] = 'created_by_id'
    mapping_hash['Sra']['Risk Leader'] = 'responsible_user_id' # RUH modification
    mapping_hash['Sra']['Responsible User'] = 'responsible_user_id'
    mapping_hash['Sra']['Quality Reviewer'] = 'reviewer_id'
    mapping_hash['Sra']['Final Approver'] = 'approver_id'
    mapping_hash['Sra']['SRA Approver'] = 'approver_id' # RUH modification
    mapping_hash['Sra']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['Sra']['Actual Completion Date'] = 'close_date'
    mapping_hash['Sra']['Describe the Current System'] = 'current_description'
    mapping_hash['Sra']['Describe Proposed Plan'] = 'plan_description'
    mapping_hash['Sra']['Responsible User\'s Comments'] = 'closing_comment'
    mapping_hash['Sra']['Quality Reviewer\'s Comments'] = 'reviewer_comment'
    mapping_hash['Sra']['Final Approver\'s Comments'] = 'approver_comment'
    mapping_hash['Sra']['Affected Departments'] = 'departments'
    mapping_hash['Sra']['Other Affected Departments'] = 'other_department'
    mapping_hash['Sra']['Affected Departments Comments'] = 'departments_comment'
    mapping_hash['Sra']['Affected Programs'] = 'programs'
    mapping_hash['Sra']['Other Affected Programs'] = 'other_program'
    mapping_hash['Sra']['Affected Programs Comments'] = 'programs_comment'
    mapping_hash['Sra']['Affected Manuals'] = 'manuals'
    mapping_hash['Sra']['Other Affected Manuals'] = 'other_manual'
    mapping_hash['Sra']['Affected Manuals Comments'] = 'manuals_comment'
    mapping_hash['Sra']['Affected Regulatory Compliances'] = 'compliances'
    mapping_hash['Sra']['Other Affected Regulatory Compliances'] = 'other_compliance'
    mapping_hash['Sra']['Affected Regulatory Compliances Comments'] = 'compliances_comment'
    mapping_hash['Sra']["#{I18n.t('srm.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['Sra']["#{I18n.t('srm.risk.mitigated.title')} Risk"] = 'risk_factor_after'
    mapping_hash['Sra']["#{I18n.t('sa.risk.baseline.title')} Severity"] = 'risk_severity'
    mapping_hash['Sra']["#{I18n.t('sa.risk.mitigated.title')} Severity"] = 'risk_severity_after'
    mapping_hash['Sra']["#{I18n.t('sa.risk.baseline.title')} Likelihood"] = 'risk_likelihood'
    mapping_hash['Sra']["#{I18n.t('sa.risk.mitigated.title')} Likelihood"] = 'risk_likelihood_after'
    mapping_hash['Sra']['Source of Input'] = 'source_of_input'
    mapping_hash['Sra']["Verifications"] = 'included_verifications'


    mapping_hash['Hazard'] = Hash.new
    mapping_hash['Hazard']['Hazard ID'] = 'id'
    mapping_hash['Hazard']['Creator'] = 'created_by_id'
    mapping_hash['Hazard']['Hazard Title'] = 'title'
    mapping_hash['Hazard']['Department'] = 'departments'
    mapping_hash['Hazard']['Lead Analyst'] = 'responsible_user_id' # FFT modification
    mapping_hash['Hazard']['Risk Leader'] = 'responsible_user_id' # RUH modification
    mapping_hash['Hazard']['Responsible User'] = 'responsible_user_id'
    mapping_hash['Hazard']['Risk Acceptor'] = 'approver_id' # FFT modification
    mapping_hash['Hazard']['SRA Approver'] = 'approver_id' # RUH modification
    mapping_hash['Hazard']['Final Approver'] = 'approver_id'
    mapping_hash['Hazard']['Date to Validate Effectiveness'] = 'due_date' # FFT modification
    mapping_hash['Hazard']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['Hazard']['Responsible User\'s Comments'] = 'recommendations_comment'
    mapping_hash['Hazard']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['Hazard']["#{Hazard.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Hazard']["Full #{Hazard.find_top_level_section.label}"] = 'included_occurrences'
    mapping_hash['Hazard']["#{I18n.t('srm.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['Hazard']["#{I18n.t('srm.risk.mitigated.title')} Risk"] = 'risk_factor_after'
    mapping_hash['Hazard']["#{I18n.t('sa.risk.baseline.title')} Severity"] = 'risk_severity'
    mapping_hash['Hazard']["#{I18n.t('sa.risk.mitigated.title')} Severity"] = 'risk_severity_after'
    mapping_hash['Hazard']["#{I18n.t('sa.risk.baseline.title')} Likelihood"] = 'risk_likelihood'
    mapping_hash['Hazard']["#{I18n.t('sa.risk.mitigated.title')} Likelihood"] = 'risk_likelihood_after'
    mapping_hash['Hazard']['Source of Input'] = 'source_of_input'
    mapping_hash['Hazard']["#{I18n.t('srm.risk.baseline.title')} Risk Score"] = 'initial_risk_score'
    mapping_hash['Hazard']["#{I18n.t('srm.risk.mitigated.title')} Risk Score"] = 'mitigated_risk_score'
    mapping_hash['Hazard']["Verifications"] = 'included_verifications'


    mapping_hash['RiskControl'] = Hash.new
    mapping_hash['RiskControl']['Creator'] = 'created_by_id'
    mapping_hash['RiskControl']['Hazard Title'] = 'title'
    mapping_hash['RiskControl']['Department'] = 'departments'
    mapping_hash['RiskControl']['Scheduled Completion Date'] = 'due_date'
    mapping_hash['RiskControl']['Date for Follow-Up/Monitor Plan'] = 'follow_up_date'
    mapping_hash['RiskControl']['Lead Analyst'] = 'responsible_user_id' # FFT modification
    mapping_hash['RiskControl']['Responsible User'] = AIRLINE_CODE == 'FFT' ? 'approver_id' : 'responsible_user_id' # Required for FFT modification
    mapping_hash['RiskControl']['Final Approver'] = 'approver_id'
    mapping_hash['RiskControl']['Risk Assessment Leader'] = 'approver_id' # RUH modification
    mapping_hash['RiskControl']['Type'] = 'control_type'
    mapping_hash['RiskControl']['Description of Risk Control/Mitigation Plan'] = 'description'
    mapping_hash['RiskControl']['Responsible User\'s Comments'] = 'closing_comment'
    mapping_hash['RiskControl']['Final Approver\'s Comments'] = 'final_comment'
    mapping_hash['RiskControl']['Source of Input'] = 'source_of_input'
    mapping_hash['RiskControl']["Verifications"] = 'included_verifications'


    mapping_hash['Safety Plan'] = Hash.new
    mapping_hash['Safety Plan']["#{I18n.t('srm.risk.baseline.title')} Risk"] = 'risk_factor'
    mapping_hash['Safety Plan']['Time Period (Days)'] = 'time_period'
    mapping_hash['Safety Plan']['Date Completed'] = 'close_date'
    mapping_hash['Safety Plan']["#{I18n.t('srm.risk.mitigated.title')} Risk"] = 'risk_factor_after'


    mapping_hash['SrmMeeting'] = Hash.new
    mapping_hash['SrmMeeting']['Review Start Date'] = 'review_start'
    mapping_hash['SrmMeeting']['Review End Date'] = 'review_end'
    mapping_hash['SrmMeeting']['Meeting Start Date'] = 'meeting_start'
    mapping_hash['SrmMeeting']['Meeting End Date'] = 'meeting_end'
    mapping_hash['SrmMeeting']['Host'] = 'meeting_host'


    mapping_hash['Checklist'] = Hash.new
    mapping_hash['Checklist']['Source of Input'] = 'checklist_get_owner'
    mapping_hash['Checklist']['Checklist Header'] = 'checklist_get_header'
    mapping_hash['Checklist']['Template'] = 'checklist_get_template'

    return mapping_hash[target][condition_field].present? ? mapping_hash[target][condition_field] : condition_field.downcase.gsub(' ','_')
  end


  def is_association(target, field_name)
    # associations = User.reflect_on_all_associations
    # associations = associations.select { |a| a.macro == :belongs_to }
    # association_foreign_keys = associations.map(&:foreign_key)
    # User.column_names.each do |column|
    #   if association_foreign_keys.include?(column)
    #     puts "#{column} is an association / relation."
    #   else
    #     puts "#{column} is not an association / relation."
    #   end
    # end
    return Object.const_get(target).reflect_on_all_associations.map(&:name).include?(field_name.to_sym)
  end


  def check_mapped_condition_field(target, condition_field)
    object_type = Object.const_get(target)
    # return (object_type.column_names.map(&:to_sym) + object_type.reflect_on_all_associations.map(&:name)).include?(condition_field.to_sym)
    return (object_type.column_names.map(&:to_sym)).include?(condition_field.to_sym)
  end

end
