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

def get_visualization_json(data, visualization)
  visualization_hash = {}
  visualization_hash[:x_axis] = visualization.x_axis
  visualization_hash[:data] = {}

  if visualization.series.present?
    visualization_hash[:series] = visualization.series
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

  else
    visualization_hash[:series] = "N/A"

    data.each do |x_axis|
      x_axis_name = x_axis[0]
      x_axis_count = x_axis[1]

      visualization_hash[:data][x_axis_name] = x_axis_count
    end

  end

  visualization_hash
end

def format_datetime(event_date)
  if CONFIG.sr::GENERAL[:submission_time_zone]
      ApplicationHelper.display_date_time_in_zone(date_time: event_date, time_zone: CONFIG::GENERAL[:time_zone], display_zone: ApplicationHelper.display_local_time_zone)
  else
    ApplicationHelper.datetime_to_string(event_date)
  end
end

def prepend_date_to_field_name(ids, target, field_name)
  event_dates = ids.map{|id| format_datetime(target.find(id).event_date)}.join(",")
  "(#{event_dates}) #{field_name}"
end

def get_target_table_ids(row)
  # row[1..-1] contains target id if a field is found for that target, else 0
  # remove 0 because it is not a valid id
  row[1..-1].flatten - [0]
end


def get_narrative_with_dates(owner, visualization, records_ids, data)
  target = Object.const_get(owner.target)
  x_axis_field = visualization.x_axis.present? ? ApplicationHelper.get_field_helper(owner, target, visualization.x_axis) : [nil, nil]
  if x_axis_field[0].present? && x_axis_field[0].is_a?(Field)
    series_field = ApplicationHelper.get_field_helper(owner, target, visualization.series)
    if x_axis_field[0].display_type == 'textarea'
      if series_field[0].present?
        data_ids = QueriesHelper.get_data_table_for_google_visualization_with_series(x_axis_field_name: visualization.x_axis,
                                                                  x_axis_field_arr: x_axis_field,
                                                                  series_field_arr: series_field,
                                                                  records_ids: records_ids,
                                                                  get_ids: true,
                                                                  query: owner)
      else
        data_ids = QueriesHelper.get_data_ids_table_for_google_visualization_sql(x_axis_field_arr: x_axis_field, records_ids: records_ids, query: owner)
      end
      data_ids[1..-1].each_with_index do |row, index|
        ids = get_target_table_ids(row)
        data[index][0] = prepend_date_to_field_name(ids, target, row[0])
      end
    end
  end
  data
end

def get_visualizations_json(owner)
  logger = Logger.new("log/export_query_result_json.log")
  query_result_visualizations = []
  records_ids = @records.map {|record| record.id}
  owner.visualizations.each do |visualization|
    begin
      data = ApplicationHelper.generate_visualization_helper(owner.id, visualization.x_axis, visualization.series, records_ids) #get_data

      if CONFIG::GENERAL[:prepend_event_date_to_query_json_export]
        data = get_narrative_with_dates(owner, visualization, records_ids, data)
      end
      if visualization.series.present?
        data[0].shift
      else
        data.shift
      end
      query_result_visualizations << get_visualization_json(data, visualization)
    rescue => error
      logger.info "Failed for Query Visualization : #{ visualization.inspect }"
    end
  end

  query_result_visualizations
end

require 'net/sftp'
require 'stringio'

desc 'Export the query result as JSON'
task export_query_result: :environment do
  include ApplicationHelper
  include QueriesHelper
  logger = Logger.new("log/export_query_result_json.log")
  logger.info "[#{Time.now}] Running"

  #------------------------------#
  host = ""
  username = ""
  password = ""
  if defined? (Object.const_get("#{AIRLINE_CODE}Config")::EXPORT_QUERY_CRED)
    creds = Object.const_get("#{AIRLINE_CODE}Config")::EXPORT_QUERY_CRED
    host = creds[:export_query_host]
    username = creds[:export_query_username]
    password = creds[:export_query_password]
  end
  #------------------------------#

  all_queries_result = {}
  @query_fields = Query.get_meta_fields('show')
  Query.all.select { |query| query.is_ready_to_export }.each do |query|
    logger.info " Query ##{query.id}"

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
    @records = QueriesHelper.get_query_results(query) # get @records
    total_records = @records.size

    query_result[:query_detail] = get_query_detail_json(@owner, total_records) #no issues
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
