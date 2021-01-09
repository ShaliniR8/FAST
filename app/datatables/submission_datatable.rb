class SubmissionDatatable < ApplicationDatatable

  private

  def records_total
    counts = Submission.can_be_accessed(@current_user).count
    { 'All' => counts }
  end


  def status_counts
    if @status_count.empty?
      # when there is no search
      return records_total
    else
      # when there is a search terms
      { 'All' => @status_count['All'] }
    end
  end


  def query_with_search_term(search_string, join_tables,start_date, end_date)
    has_date_range = start_date.present? && end_date.present?
    case status
    when 'All'
      if has_date_range
        Submission.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .within_timerange(start_date, end_date)
              .group("#{Submission.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        Submission.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .group("#{Submission.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    else
      if has_date_range
        Submission.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .within_timerange(start_date, end_date)
              .group("#{Submission.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        Submission.joins(join_tables)
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .group("#{Submission.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    end
  end


  def query_without_search_term(search_string, join_tables,start_date, end_date)
    case status
    when 'All'
      Submission.joins(join_tables)
                .order("#{sort_column} #{sort_direction}")
                .can_be_accessed(@current_user)
                .group("#{Submission.table_name}.id")
                .limit(params['length'].to_i)
                .offset(params['start'].to_i)
    else
      Submission.joins(join_tables)
                .order("#{sort_column} #{sort_direction}")
                .can_be_accessed(@current_user)
                .group("#{Submission.table_name}.id")
                .limit(params['length'].to_i)
                .offset(params['start'].to_i)
    end
  end


  def update_status_count(search_string, join_tables, start_date, end_date)
    if start_date.nil? && end_date.nil?
      {
        'All' => Submission.joins(join_tables)
                       .where(search_string.join(' and '))
                       .can_be_accessed(@current_user)
                       .count
      }
    else
      {
        'All' => Submission.joins(join_tables)
                       .where(search_string.join(' and '))
                       .can_be_accessed(@current_user)
                       .within_timerange(start_date, end_date)
                       .count
      }
    end
  end
end
