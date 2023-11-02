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

def get_narrative_with_dates(owner, visualization, data, data_ids)
  target = Object.const_get(owner.target)

  if visualization.x_axis.present?
    x_axis_field = ApplicationHelper.get_field_helper(owner, target, visualization.x_axis)
    x_axis_field_type = x_axis_field[0].display_type

    data_ids[1..-1].each_with_index do |row, index|
      ids = row[1..-1] - [0]
      data[index][0] = x_axis_field_type == 'textarea' ?
                                            "(#{ids.map{|id| target.find(id).event_date.to_s.gsub(" UTC", "")}.join(",")}) #{row[0]}"
                                              :  row[0]
    end
  end

  data

end

def get_visualizations_json(owner)
  query_result_visualizations = []
  records_ids = @records.map {|record| record.id}
  owner.visualizations.each do |visualization|
    begin
      data = ApplicationHelper.generate_visualization_helper(owner.id, visualization.x_axis, visualization.series, records_ids) #get_data
      data_ids = ApplicationHelper.generate_visualization_helper(owner.id, visualization.x_axis, visualization.series, records_ids, get_ids:true) #get_data

      if CONFIG::GENERAL[:prepend_event_date_to_query_json_export]
        data = get_narrative_with_dates(owner, visualization, data, data_ids)
      end

      if visualization.series.present?
        data[0].shift
      else
        data.shift
      end
      query_result_visualizations << get_visualization_json(data, visualization)
    rescue
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
  File.open("export_query_result.json", "w") do |f|
    f.write(all_queries_result.to_json)
  end
  # Net::SFTP.start(host, username, :password => password) do |sftp|
  #   begin
  #     io = StringIO.new all_queries_result.to_json
  #     file_name = "#{Time.current.strftime("%Y%m%d%H%M")}.json"
  #     target = "/Usr/F9ProsafeT/Incoming/#{file_name}"

  #     sftp.upload!(io, target)

  #     p 'UPLOAD SUCCESSFUL'
  #   rescue Exception => e
  #     p e.message
  #     p 'UPLOAD FAILED'
  #   end
  # end
end
