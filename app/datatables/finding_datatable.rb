class FindingDatatable < ApplicationDatatable
  private

  def query_with_search_term(search_string, join_tables, start_date, end_date)
    if !@current_user.has_access(object.table_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true) && object.table_name != "safety_plans"
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
        records = object.joins(join_tables)
              .where(id: @recs.map(&:id))
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date)
              .group("#{object.table_name}.id")

        records = temp_handle_findings_sub_menus_for_records(records, search_string, status, start_date, end_date)
        records.slice(params['start'].to_i, params['length'].to_i)
      else
        records = object.joins(join_tables)
              .where(id: @recs.map(&:id))
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")

        records = temp_handle_findings_sub_menus_for_records(records, search_string, status, start_date, end_date)
        records.slice(params['start'].to_i, params['length'].to_i)
      end
    when 'Overdue'
      records = object.joins(join_tables)
            .where(id: @recs.map(&:id))
            .where(search_string.join(' and '))
            .order("#{sort_column} #{sort_direction}")
            .within_timerange(start_date, end_date)
            .where(["#{params[:controller]}.due_date < :today and #{params[:controller]}.status != :status", {today: Time.now.to_date, status: 'Completed'}])

        records = temp_handle_findings_sub_menus_for_records(records, search_string, status, start_date, end_date)
        records.slice(params['start'].to_i, params['length'].to_i)

    else
      if has_date_range
        records = object.where(status: status)
              .joins(join_tables)
              .where(id: @recs.map(&:id))
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .within_timerange(start_date, end_date)
              .group("#{object.table_name}.id")

        records = temp_handle_findings_sub_menus_for_records(records, search_string, status, start_date, end_date)
        records.slice(params['start'].to_i, params['length'].to_i)
      else
        records = object.where(status: status)
              .joins(join_tables)
              .where(id: @recs.map(&:id))
              .where(search_string.join(' and '))
              .order("#{sort_column} #{sort_direction}")
              .group("#{object.table_name}.id")

        records = temp_handle_findings_sub_menus_for_records(records, search_string, status, start_date, end_date)
        records.slice(params['start'].to_i, params['length'].to_i)
      end
    end
  end

  def temp_handle_findings_sub_menus_for_counts(counts, search_string)
    match_word = /owner_type = \'(?<obj>\w+)\'/.match search_string.last
    # byebug
    # ["findings.id like '%145%'", "owner_type = 'Audit'"]
    if params[:advance_search][:type].present?
      if %w(Audit Inspection Evaluation Investigation).include? match_word[:obj]
        object.where(owner_type: 'ChecklistRow')
            .keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }
            .group_by { |x| x.status }
            .each { |k,v|
              if counts[k].nil?
                counts[k] = v.size
              else
                counts[k] += v.size
              end
            }
        counts['Overdue'] += object.where(["#{params[:controller]}.due_date < :today and #{params[:controller]}.status != :status", {today: Time.now.to_date, status: 'Completed'}]).where(owner_type: 'ChecklistRow').keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }.size
      end
    end
    return counts
  end


  def temp_handle_findings_sub_menus_for_records(records, search_string, status, start_date, end_date)
    match_word = /owner_type = \'(?<obj>\w+)\'/.match search_string.last

    if params[:advance_search][:type].present?
      if %w(Audit Inspection Evaluation Investigation).include? match_word[:obj]
        if start_date.present? && end_date.present?
          if status == 'All'
            records = records + object.within_timerange(start_date, end_date).where(owner_type: 'ChecklistRow').keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }
          elsif status == 'Overdue'
            records = records + object.within_timerange(start_date, end_date).where(["#{params[:controller]}.due_date < :today and #{params[:controller]}.status != :status", {today: Time.now.to_date, status: 'Completed'}]).where(owner_type: 'ChecklistRow').keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }
          else
            records = records + object.where(status: status).within_timerange(start_date, end_date).where(owner_type: 'ChecklistRow').keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }
          end
        else
          if status == 'All'
            records = records + object.where(owner_type: 'ChecklistRow').keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }
          elsif status == 'Overdue'
            records = records + object.where(owner_type: 'ChecklistRow').where(["#{params[:controller]}.due_date < :today and #{params[:controller]}.status != :status", {today: Time.now.to_date, status: 'Completed'}]).keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }
          else
            records = records + object.where(status: status).where(owner_type: 'ChecklistRow').keep_if { |x| x.owner.checklist.owner_type == match_word[:obj] }
          end
        end
      end
    end
    return records
  end


  def update_status_count(search_string, join_tables, start_date, end_date)
    if start_date.nil? && end_date.nil?
      @status_count = object.joins(join_tables)
                            .where(id: @recs.map(&:id))
                            .where(search_string.join(' and '))
                            .group("#{object.table_name}.status").count
    else
      @status_count = object.joins(join_tables)
                            .where(id: @recs.map(&:id))
                            .where(search_string.join(' and '))
                            .within_timerange(start_date, end_date)
                            .group("#{object.table_name}.status").count
    end

    @status_count['Overdue'] = object.joins(join_tables)
                                     .within_timerange(start_date, end_date)
                                     .where(id: @recs.map(&:id))
                                     .where(search_string.join(' and '))
                                     .group("#{object.table_name}.id")
                                     .select{ |x| x.overdue }.size
    @status_count = temp_handle_findings_sub_menus_for_counts(@status_count, search_string)
    @status_count
  end

end