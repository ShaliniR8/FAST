# Finds queries that reach threshold and mail to distribution lists
task :query_threshold_alerts => :environment do

  @log = Logger.new("log/query_threshold_alert_#{Rails.env}.log")
  @log.level = Logger::INFO
  @log.datetime_format = "%Y-%m-%d %H:%M:%S"
  @log.info "======================================================"

  day_of_week = Date.today.cwday
  day_of_month = Date.today.day

  queries = Query.find(:all)
  filtered = []
  # for each query
  # size = QueriesHelper.get_query_results(query).size
  # filtered.push [query.id, query.distribution_list_ids] if size >= threshold


  controller = QueriesController.new

  filtered.each do |query|
      filename = "Query ##{query[0]}"
      # DistributionListConnection match query[1] get user
      # emails
      # mail(to: emails, subject: subject).deliver
  end

end
