class CorrectiveActionDatatable < ApplicationDatatable

  private

  def records_total
    search_string = []
    if !@current_user.has_access('corrective_actions', 'admin', admin: true, strict: true)
      status_queries = []
      status_queries << "created_by_id = #{@current_user.id}"
      status_queries << "responsible_user_id = #{@current_user.id} AND status in ('Assigned', 'Completed')"
      status_queries << "approver_id = #{@current_user.id} AND status in ('Pending Approval', 'Completed')"
      search_string << "(#{status_queries.join(' OR ')})"
    end

    counts = object.where(search_string.join(' AND ')).group(:status).count

    params[:statuses].reduce({}) { |acc, status|
      status_count = case status
        when 'All'
          counts.values.sum
        else
          counts[status].nil? ? 0 : counts[status]
        end

      acc.update( status => status_count)
    }
  end


  def query_with_search_term(search_string, join_tables,start_date, end_date)

    if !@current_user.has_access('corrective_actions', 'admin', admin: true, strict: true)
      status_queries = []
      status_queries << "created_by_id = #{@current_user.id}"
      status_queries << "responsible_user_id = #{@current_user.id} AND status in ('Assigned', 'Completed')"
      status_queries << "approver_id = #{@current_user.id} AND status in ('Pending Approval', 'Completed')"
      search_string << "(#{status_queries.join(' OR ')})"
    end

    has_date_range = start_date.present? && end_date.present?
    case status
    when 'All'
      if has_date_range
        object.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date).group("#{object.table_name}.id")
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
    else
      if has_date_range
        object.where(status: status)
              .joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date).group("#{object.table_name}.id")
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

    if !@current_user.has_access('corrective_actions', 'admin', admin: true, strict: true)
      status_queries = []
      status_queries << "created_by_id = #{@current_user.id}"
      status_queries << "responsible_user_id = #{@current_user.id} AND status in ('Assigned', 'Completed')"
      status_queries << "approver_id = #{@current_user.id} AND status in ('Pending Approval', 'Completed')"
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
