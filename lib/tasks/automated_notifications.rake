namespace :notifications do

  desc "Send automated notifications/reminders."
  task :automated_notifications => :environment do
    begin
      all_rules = AutomatedNotification.all

      all_rules.each do |rule|
        object_type = rule.object_type
        anchor_date_field = rule.anchor_date_field
        audience_field = rule.audience_field
        anchor_status = rule.anchor_status
        interval = rule.interval
        subject = rule.subject
        content = rule.content

        records = Object.const_get(object_type.classify)
          .where("status = ? AND DATE(#{anchor_date_field}) = ?",
            anchor_status, Time.now.in_time_zone.to_date + interval.days)

        puts "Alert ##{rule.id} count: #{records.length}"
        records.each do |record|
          user_or_users = record.send(audience_field)
          if user_or_users.is_a?(Array)
            user_or_users.each do |u|
              if u.is_a?(User)
                send_email(u, subject, content, record)
              end
            end
          elsif user_or_users.is_a?(Fixnum)
            user = User.find(user_or_users) rescue nil
            if user.present?
              send_email(user, subject, content, record)
            end
          else
            user = user_or_users.user rescue nil
            if user.present?
              send_email(user, subject, content, record)
            end
          end
        end
      end
    rescue => error
      location = "notifications:automated_notifications"
      subject = "Rake Task Error Encountered In #{location.upcase}"
      error_message = error.message
      NotifyMailer.notify_rake_errors(subject, error_message, location)
    end
  end

  def send_email(user, subject, content, record)
    NotifyMailer.automated_reminder(user, subject, content, record)
    content = content[0..251] + '...' if content.length > 255
    record.notices.create({users_id: user.id, content: content})
  end

  desc 'Send out user-designated email reminders'
  task :send_reminders => :environment do

    Notice.where('create_email = TRUE AND
      (expire_date > ? OR expire_date IS NULL) AND
      (start_date < ? OR start_date IS NULL)',
      DateTime.now,
      DateTime.now
    ).include(:user).each do |notice|
      NotifyMailer.notify(notice.user, notice.content, 'ProSafeT User Notice')
      notice.create_email = false
      puts "Email sent to #{notice.user.full_name} for Notice ##{notice.id}" if notice.save!
    end
  end

  desc 'Send notification to distribution list groups when Query threshold is reached'
  task :query_threshold_alert => :environment do
    include QueriesHelper
    begin
      queries = Query.find(:all).select {|instance| instance[:threshold] != nil}
      threshold_exceeded = queries.select {|query| QueriesHelper.get_query_results_ids(query).size >= query.threshold}
      map_user_query = Hash.new
      threshold_exceeded.each do |query|
        distros_ids = query.distribution_list_ids
        distros = DistributionList.preload(:distribution_list_connections).where(id: distros_ids)
        user_ids = distros.map(&:get_user_ids).flatten.uniq()
        user_ids.each do |u|
          if map_user_query[u] == nil
            map_user_query[u] = [{query_id:query.id, message: " => Threshold: #{query.threshold}, Total results under query: #{QueriesHelper.get_query_results_ids(query).size}"}]
          else
            map_user_query[u] << {query_id:query.id, message: " => Threshold: #{query.threshold}, Total results under query: #{QueriesHelper.get_query_results_ids(query).size}"}
          end
        end
      end
      map_user_query.each do |user_id, queries|
        subject = "Threshold alert for Queries"
        NotifyMailer.automated_reminder(User.find(user_id), subject, "The following Queries have exceeded their thresholds.", queries)
      end
    end
  end

  desc 'Send notification to distribution list groups when Visualization threshold is reached'
  task :visualization_threshold_alert => :environment do
    include QueriesHelper
    begin
      visualizations = QueryVisualization.find(:all).select {|instance| instance[:threshold] != nil}
      threshold_exceeded = visualizations.select {|viz| get_counts(viz).max >= viz.threshold}
      threshold_exceeded = threshold_exceeded.group_by(&:owner_id)
      controller = QueriesController.new
      map_user_query = Hash.new
      threshold_exceeded.each do |owner_id, visualizations|
        @query = Query.find(owner_id)
        distros = DistributionList.preload(:distribution_list_connections).where(id: @query.distribution_list_ids)
        user_ids = distros.map(&:get_user_ids).flatten.uniq()
        user_ids.each do |u|
          html = controller.render_to_string(
            template: 'queries/_visualizations_pdf.html.slim',
            locals: {owner: @query, visualizations: visualizations },
            layout: false
          )
          pdf = PDFKit.new(html)
          pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
          attachment = pdf.to_pdf
          filename = "Query_#{@query.id}_visualizations_threshold_alert.pdf"
          if map_user_query[u] == nil
            map_user_query[u] = {
              :query_ids => [{query_id:owner_id}],
              :attachments => [{:attachment => attachment, :filename => filename}]
            }
          else
            map_user_query[u][:query_ids] << {query_id:owner_id}
            map_user_query[u][:attachments] << {:attachment => attachment, :filename => filename}
            map_user_query[u] = {
              :query_ids => map_user_query[u][:query_ids],
              :attachments => map_user_query[u][:attachments]
            }
          end
        end
      end
      map_user_query.each do |user_id, record|
        subject = "Threshold alert for Query Visualizations"
        message = "Some of the visualizations under the following queries have reached or exceeded the set visualization threshold. Please open attachments to inspect visualizations for each query."
        NotifyMailer.automated_reminder(User.find(user_id), subject, message , record[:query_ids], record[:attachments])
      end
    end
  end

  def get_counts(viz)
    @query = Query.find(viz.owner_id)
    @object_type = Object.const_get(@query.target)
    field_label = viz.x_axis
    @x_axis_field = QueryVisualization.get_field(@query, @object_type, field_label)
    records_ids = QueriesHelper.get_query_results_ids(@query)
    table = QueriesHelper.get_data_table_for_google_visualization_sql(x_axis_field_arr:@x_axis_field, records_ids:records_ids, query: @query)
    table[1..-1].map {|t| t[1]}
  end

end

