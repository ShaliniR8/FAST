# Finds subscriptions and send query digest through email
task :send_daily_digest => :environment do

  @log = Logger.new("log/daily_digest_#{Rails.env}.log")
  @log.level = Logger::INFO
  @log.datetime_format = "%Y-%m-%d %H:%M:%S"
  @log.info "======================================================"

  day_of_week = Date.today.cwday
  day_of_month = Date.today.day

  subscriptions = []
  subscriptions += Subscription.where(frequency: 1, owner_type: "Query")
  subscriptions += Subscription.where(frequency: 2, day: day_of_week, owner_type: "Query")
  subscriptions += Subscription.where(frequency: 3, day: day_of_month, owner_type: "Query")

  controller = QueriesController.new

  subscriptions.group_by(&:owner).each do |query, subs|
    @log.info "[#{Time.now}] Query: #{query.id}, subscribers: #{subs.map(&:user_id)}"
    begin
      html = controller.render_to_string(template: 'queries/_pdf.html.slim', locals: {
        owner: query,
      }, layout: false)

      pdf = PDFKit.new(html)
      pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
      pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
      filename = "Query ##{query.id}"
      attachment = pdf.to_pdf
      NotifyMailer.send_query_digest(users: subs.map(&:user), query: query, file: attachment)
    rescue => error
      @log.info "[#{Time.now}] ERROR: #{error}"
      @log.info "[#{Time.now}] ERROR_MESSAGE: #{error.message}"
      @log.info "[#{Time.now}] ERROR_STACK_TRACE: #{error.backtrace}"
    end
  end

end
