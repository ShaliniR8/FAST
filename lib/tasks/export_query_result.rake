# no issues
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

# no issues, combined get_visualization_w_series and wo_series into one function
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


def get_visualizations_json(owner)
  query_result_visualizations = []
  records_ids = @records.map {|record| record.id}
  owner.visualizations.each do |visualization|
    data = ApplicationHelper.generate_visualization_helper(owner.id, visualization.x_axis, visualization.series, records_ids) #get_data
    if visualization.series.present?
      data[0].shift
    else
      data.shift
    end
    query_result_visualizations << get_visualization_json(data, visualization)
  end

  query_result_visualizations
end

require 'net/sftp'
require 'stringio'

desc 'Export the query result as JSON'
task export_query_result: :environment do
  include ApplicationHelper
  include QueriesHelper

  #------------------------------#
  host = "secure.flyfrontier.com"
  username = "F9ProsafeT"
  password = "OwTX4NX&"
  #------------------------------#

  all_queries_result = {}
  logger = Logger.new("log/export_query_benchmark.log")
  @query_fields = Query.get_meta_fields('show')
  start = Time.now
  Query.all.select { |query| query.is_ready_to_export }.each do |query|
    puts " Query ##{query.id}"

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
  stop = Time.now
  logger.info "Time taken for loop : #{stop - start}"
  Net::SFTP.start(host, username, :password => password) do |sftp|
    begin
      io = StringIO.new all_queries_result.to_json
      logger.info "#{all_queries_result.to_json}"
      file_name = "#{Time.current.strftime("%Y%m%d%H%M")}.json"
      target = "/Usr/F9ProsafeT/Incoming/#{file_name}"

      # sftp.upload!(io, target)

      p 'UPLOAD SUCCESSFUL'
    rescue Exception => e
      p e.message
      p 'UPLOAD FAILED'
    end
  end
end
