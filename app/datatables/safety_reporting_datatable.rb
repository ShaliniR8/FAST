class SafetyReportingDatatable < ApplicationDatatable

  private

  def records_total
    counts = object.can_be_accessed(@current_user).group(:status).count

    params[:statuses].reduce({}) { |acc, status|
      status_count = case status
        when 'All'
          counts.values.sum
        else
          counts[status].nil? ? 0 : counts[status]
        end

      acc.update(status => status_count)
    }
  end


  def status_counts
    if @status_count.empty?
      # when there is no search
      return records_total
    else
      # when there is a search terms
      counts = @status_count
    end

    params[:statuses].reduce({}) { |acc, status|
      status_count = case status
        when 'All'
          counts.values.sum
        else
          counts[status].nil? ? 0 : counts[status]
        end

      acc.update(status => status_count)
    }
  end


  def query_with_search_term(search_string, join_tables,start_date, end_date)
    has_date_range = start_date.present? && end_date.present?
    case status
    when 'All'
      if has_date_range
        object.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .within_timerange(start_date, end_date).group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        object.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user).group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    else
      if has_date_range
        object.where(status: status)
              .joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .within_timerange(start_date, end_date).group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        object.where(status: status)
              .joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user).group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    end
  end


  def query_without_search_term(search_string, join_tables,start_date, end_date)
    case status
    when 'All'
      object.joins(join_tables)
            .order("#{sort_column} #{sort_direction}")
            .can_be_accessed(@current_user).group("#{object.table_name}.id")
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)
    else
      object.joins(join_tables)
            .where(status: status)
            .order("#{sort_column} #{sort_direction}")
            .group("#{object.table_name}.id")
            .can_be_accessed(@current_user)
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)
    end
  end


  def update_status_count(search_string, join_tables, start_date, end_date)
    if start_date.nil? && end_date.nil?
      object.joins(join_tables)
            .where(search_string.join(' and '))
            .can_be_accessed(@current_user)
            .group("#{object.table_name}.status").count
    else
      object.joins(join_tables)
            .where(search_string.join(' and '))
            .can_be_accessed(@current_user)
            .within_timerange(start_date, end_date)
            .group("#{object.table_name}.status").count
    end
  end

end
