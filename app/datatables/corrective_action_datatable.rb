class CorrectiveActionDatatable < ApplicationDatatable

  private

  def records_total
    search_string = []
    if !@current_user.has_access(object.table_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      status_queries = []
      status_queries << "created_by_id = #{@current_user.id}"
      status_queries << "responsible_user_id = #{@current_user.id}"
      status_queries << "approver_id = #{@current_user.id}"
      status_queries << "reviewer_id = #{@current_user.id}"  if object.table_name == 'sras'
      search_string << "(#{status_queries.join(' OR ')})"
    end

    start_date = params[:advance_search][:start_date]
    end_date = params[:advance_search][:end_date]
    counts = object.where(search_string.join(' AND '))
                   .within_timerange(start_date, end_date)
                   .group(:status).count

    params[:statuses].reduce({}) { |acc, status|
      status_count = case status
        when 'All'
          if counts['Overdue'].nil?
            counts.values.sum
          else
            counts.values.sum - counts['Overdue']
          end
        when 'Overdue'
            object.where(search_string.join(' AND ')).select{|x| x.overdue}.size
        else
          counts[status].nil? ? 0 : counts[status]
        end

      acc.update( status => status_count)
    }
  end


  def query_with_search_term(search_string, join_tables,start_date, end_date)

    if !@current_user.has_access(object.table_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      status_queries = []
      status_queries << "created_by_id = #{@current_user.id}"
      status_queries << "responsible_user_id = #{@current_user.id}"
      status_queries << "approver_id = #{@current_user.id}"
      status_queries << "reviewer_id = #{@current_user.id}"  if object.table_name == 'sras'
      search_string << "(#{status_queries.join(' OR ')})"
    end

    has_date_range = start_date.present? && end_date.present?

    case status
    when 'All'
      if has_date_range
        object.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date)
              .group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
       object.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end

    when 'Overdue'
      object.joins(join_tables).joins(join_tables)
            .where(search_string.join(' and '))
            .order("#{sort_column} #{sort_direction}")
            .where(["due_date < :today and status != :status", {today: Time.now.to_date, status: 'Completed'}])
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)

    else
      if has_date_range
        object.where(status: status)
              .joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date)
              .group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        object.where(status: status)
              .joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    end
  end


  def query_without_search_term(search_string, join_tables,start_date, end_date)

    if !@current_user.has_access(object.table_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      status_queries = []
      status_queries << "created_by_id = #{@current_user.id}"
      status_queries << "responsible_user_id = #{@current_user.id}"
      status_queries << "approver_id = #{@current_user.id}"
      status_queries << "reviewer_id = #{@current_user.id}"  if object.table_name == 'sras'
      search_string << "(#{status_queries.join(' OR ')})"
    end

    case status
    when 'All'
      object.joins(join_tables)
            .where(search_string.join(' and '))
            .order("#{sort_column} #{sort_direction}")
            .group("#{object.table_name}.id")
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)

    when 'Overdue'
      object.joins(join_tables)
            .order("#{sort_column} #{sort_direction}")
            .where(search_string.join(' AND '))
            .where(["due_date < :today and status != :status", {today: Time.now.to_date, status: 'Completed'}])
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)

    else
      object.joins(join_tables)
            .where(status: status)
            .where(search_string.join(' and '))
            .order("#{sort_column} #{sort_direction}")
            .group("#{object.table_name}.id")
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)
    end
  end


  def status_counts
    if @status_count.empty?
      # when there is no search
      return @records_total
    else
      # when there is a search terms
      counts = @status_count
    end

    params[:statuses].reduce({}) { |acc, status|
      status_count = case status
        when 'All'
          if counts['Overdue'].nil?
            counts.values.sum
          else
            counts.values.sum - counts['Overdue']
          end
        else
          counts[status].nil? ? 0 : counts[status]
        end

      acc.update(status => status_count)
    }
  end



  def update_status_count(search_string, join_tables, start_date, end_date)
    if start_date.nil? && end_date.nil?
      @status_count = object.joins(join_tables)
                            .where(search_string.join(' and '))
                            .group("#{object.table_name}.status").count
    else
      @status_count = object.joins(join_tables)
                            .where(search_string.join(' and '))
                            .within_timerange(start_date, end_date)
                            .group("#{object.table_name}.status").count
    end
  end

end
