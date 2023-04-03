class OshaSubmissionDatatable < SubmissionDatatable
  
  private 

  def records_total
    counts = OshaSubmission.can_be_accessed(@current_user).count
    { 'All' => counts }
  end

  def columns
    OshaSubmission.get_meta_fields_keys(['index'], @current_user)
  end


  def query_with_search_term(search_string, join_tables,start_date, end_date)
    has_date_range = start_date.present? && end_date.present?
    case status
    when 'All'
      if has_date_range
        OshaSubmission.joins(join_tables)
              .where(id: @recs.map(&:id))
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .within_timerange(start_date, end_date)
              .group("#{Submission.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        OshaSubmission.joins(join_tables)
              .where(id: @recs.map(&:id))
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .group("#{Submission.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    else
      if has_date_range
        OshaSubmission.joins(join_tables)
              .where(id: @recs.map(&:id))
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user)
              .within_timerange(start_date, end_date)
              .group("#{Submission.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      else
        OshaSubmission.joins(join_tables)
              .where(id: @recs.map(&:id))
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
      OshaSubmission.joins(join_tables)
                .order("#{sort_column} #{sort_direction}")
                .can_be_accessed(@current_user)
                .group("#{Submission.table_name}.id")
                .limit(params['length'].to_i)
                .offset(params['start'].to_i)
    else
      OshaSubmission.joins(join_tables)
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
        'All' => OshaSubmission.joins(join_tables)
                       .where(id: @recs.map(&:id))
                       .where(search_string.join(' and '))
                       .can_be_accessed(@current_user)
                       .count
      }
    else
      {
        'All' => OshaSubmission.joins(join_tables)
                       .where(id: @recs.map(&:id))
                       .where(search_string.join(' and '))
                       .can_be_accessed(@current_user)
                       .within_timerange(start_date, end_date)
                       .count
      }
    end
  end

end
