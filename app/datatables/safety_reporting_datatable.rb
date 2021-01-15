class SafetyReportingDatatable < ApplicationDatatable

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @status_count = {}

    @object_access_filtered = object.can_be_accessed(@current_user)
    @records_total = records_total
    @status_counts = {}
  end

  private

  def records_total
    counts = @object_access_filtered.group(:status).count

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
      return @records_total
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
        @object_access_filtered.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date)
              .group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        @object_access_filtered.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    else
      if has_date_range
        @object_access_filtered.where(status: status)
              .joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date)
              .group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        @object_access_filtered.where(status: status)
              .joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    end
  end


  def query_without_search_term(search_string, join_tables, start_date, end_date)
    case status
    when 'All'
      @object_access_filtered.joins(join_tables)
            .order("#{sort_column} #{sort_direction}")
            .group("#{object.table_name}.id")
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)
    else
      @object_access_filtered.joins(join_tables)
            .where(status: status)
            .order("#{sort_column} #{sort_direction}")
            .group("#{object.table_name}.id")
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)
    end
  end


  def update_status_count(search_string, join_tables, start_date, end_date)
    if start_date.nil? && end_date.nil?
      @object_access_filtered.joins(join_tables)
            .where(search_string.join(' and '))
            .group("#{object.table_name}.status").count
    else
      @object_access_filtered.joins(join_tables)
            .where(search_string.join(' and '))
            .within_timerange(start_date, end_date)
            .group("#{object.table_name}.status").count
    end
  end


  def records_adv_searched
    adv_params = params[:advance_search]

    search_fields = [
      {
        term: adv_params[:searchterm_1],
        field: adv_params[:field_1],
        start_date: adv_params[:start_date_1],
        end_date: adv_params[:end_date_1]
      },
      {
        term: adv_params[:searchterm_2],
        field: adv_params[:field_2],
        start_date: adv_params[:start_date_2],
        end_date: adv_params[:end_date_2]
      },
      {
        term: adv_params[:searchterm_3],
        field: adv_params[:field_3],
        start_date: adv_params[:start_date_3],
        end_date: adv_params[:end_date_3]
      },
      {
        term: adv_params[:searchterm_4],
        field: adv_params[:field_4],
        start_date: adv_params[:start_date_4],
        end_date: adv_params[:end_date_4]
      }
    ]

    # Update columns params
    columns_param = params[:columns]

    start_date = nil
    end_date = nil

    search_fields.each do |field|
      if field[:term].present? # what column to search
        if field[:field].present? # what term to search
          handle_search_term(field[:term], field[:field], columns_param)
        elsif field[:start_date].present? && field[:end_date].present?
          start_date = field[:start_date].to_date
          end_date = field[:end_date].to_date
          handle_search_date(field[:term], start_date, end_date, @object_access_filtered)
        end
      end
    end

    [start_date.to_datetime, end_date.to_datetime] rescue [nil, nil]
  end

end
