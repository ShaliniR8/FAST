class ApplicationDatatable
  include ApplicationHelper
  delegate :params, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @status_count = {}

    @records_total = records_total
    @status_counts = {}
  end


  def as_json(option = {})
    {
      draw: params['draw'].to_i,
      data: data,
      recordsTotal: @records_total[status],
      recordsFiltered: status_counts[status],
      statusCounts: status_counts,
      searchTerms: handle_search[:search_columns_and_terms_map]
    }
  end


  private

  def data
    format_index_column_data(records: records, object_name: object_name)
  end


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

    start_date, end_date = handle_time_zone(start_date, end_date)

    test_1 = object.where(search_string.join(' AND '))
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
          object.where(search_string.join(' AND ')).select{ |x| x.overdue }.size
        else
          counts[status].nil? ? 0 : counts[status]
        end

      acc.update( status => status_count)
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


  def columns
    if ["Record", "Submission"].include? (object.name)
      object.get_meta_fields_keys(['index'], @current_user)
    else
      object.get_meta_fields_keys('index')
    end
  end


  def sort_column
    column = columns[params[:order]['0'][:column].to_i]
    column = column.nil? ? "id" : column 
    column = column.include?('#') ? column.split('#').second : column
    column == 'id' ? "#{object.table_name}.#{column}" : column
  end


  def sort_direction
    params[:order]['0'][:dir] == "desc" ? "desc" : "asc"
  end


  def status
    status = params['status']
  end



  def object_name
    params[:controller].classify
  end


  def object
    if params[:controller] == 'audits'
      return Object.const_get(params[:controller].classify).where("audits.id not in (?)", Recurrence.where(form_type: "Audit").map(&:template_id).size == 0 ? [0] : Recurrence.where(form_type: "Audit").map(&:template_id))
    elsif params[:controller] == 'inspections'
      return Object.const_get(params[:controller].classify).where("inspections.id not in (?)", Recurrence.where(form_type: "Inspection").map(&:template_id).size == 0 ? [0] : Recurrence.where(form_type: "Inspection").map(&:template_id))
    elsif params[:controller] == 'evaluations'
      return Object.const_get(params[:controller].classify).where("evaluations.id not in (?)", Recurrence.where(form_type: "Evaluation").map(&:template_id).size == 0 ? [0] : Recurrence.where(form_type: "Evaluation").map(&:template_id))
    else
      return Object.const_get(params[:controller].classify)
    end
  end


  def records
    start_date, end_date = update_adv_search_columns_and_get_start_end_date
    search_params = handle_search
    join_tables = prepare_join_tables(search_params)
    if dashboard_risk_matrix_link
      adv_params = params[:advance_search]
      query_records_for_risk(search_params, adv_params, join_tables)
    else
      query_records(search_params, join_tables, start_date, end_date)
    end
  end


  def dashboard_risk_matrix_link
    adv_params = params[:advance_search]
    adv_params[:advance_search] && %w[severity likelihood severity_after likelihood_after].include?(adv_params[:searchterm_1])
  end


  def update_adv_search_columns_and_get_start_end_date
    start_date, end_date = records_adv_searched # apply adavanced search and update params
    if start_date.nil? && end_date.nil?
      start_date = params[:advance_search][:start_date].to_datetime rescue nil
      end_date = params[:advance_search][:end_date].to_datetime rescue nil
    end

    handle_time_zone(start_date, end_date)
  end


  def handle_time_zone(start_date, end_date)
    if start_date.present? && end_date.present?
      if start_date.is_a?(String)
        start_date = start_date.to_datetime
      end
      if end_date.is_a?(String)
        end_date = end_date.to_datetime
      end
      offset = (start_date.in_time_zone(CONFIG::GENERAL[:time_zone]).utc_offset / 3600).hours

      start_date = start_date - offset
      end_date = end_date - offset
    end

    return [start_date, end_date]
  end


  def handle_search
    # ex) {"1"=>"New"} - {<column_index> => <term>}
    search_columns_and_terms_map = params[:columns].reduce({}) { |acc, (key,value)|
      acc.merge({key => value[:search][:value]})
    }.keep_if { |key,value| value.present? }

    # ex) ["status like '%New%'"] - [<column_name> like '%<search_terms>%']
    search_string = []
    search_columns_and_terms_map.each do |index, term|
      column = columns[index.to_i]

      # ex) 'responsible_user#responsible_user.full_name' - 'responsible_user.full_name'
      # ex) 'findings.id'                                 - 'findings.id'
      # ex) 'id'                                          - 'audits.id'

      column = column.include?('#') ? column.split('#').second : column
      column = column.include?('.') ? column : "#{object.table_name}.#{column}"

      search_string << "#{column} like '%#{term}%'"
    end

    if params[:advance_search][:type].present?
      search_string << "owner_type = '#{params[:advance_search][:type]}'"
    end

    {search_columns_and_terms_map: search_columns_and_terms_map, search_string: search_string}
  end


  def prepare_join_tables(search_params)
    # ex) object.joins(:template).where("templates.name LIKE ?", "%#{'inflight'}%")
    # ex) object.joins(join_tables).where(search_string.join(' or '))
    join_tables = columns.select.with_index { |column, index|

      # helper method to filter join columns
      column = column.include?('#') ? column.split('#').second : column

      orderable = column == sort_column
      searchable = search_params[:search_columns_and_terms_map][index.to_s].present?

      (orderable || searchable) && column.include?('.')
    }
    .map { |column|
      case column
      when 'users.full_name'
        :created_by
      when 'templates.name'
        :template
      when 'responsible_user#responsible_user.full_name'
        "LEFT JOIN users AS responsible_user ON #{object.table_name}.responsible_user_id = responsible_user.id"
      when 'approver#approver.full_name'
        "LEFT JOIN users AS approver ON #{object.table_name}.approver_id = approver.id"
      when 'occurrences.value'
        "LEFT JOIN occurrences ON #{object.table_name}.id = occurrences.owner_id and occurrences.owner_type = '#{object_name}'"
      when 'verifications.status'
        "LEFT JOIN verifications ON #{object.table_name}.id = verifications.owner_id and verifications.owner_type = '#{object_name}'"
      when 'findings.id'
        "LEFT JOIN findings ON #{object.table_name}.id = findings.owner_id and findings.owner_type = '#{object_name}'"
      else
        column.split('.').first.to_sym
      end
    }
    join_tables
  end


  def query_records(search_params, join_tables, start_date, end_date)
    search_string = search_params[:search_string]
    has_no_search_term = search_string.empty? && start_date.nil? && end_date.nil?
    if has_no_search_term
      query_without_search_term(search_string, join_tables,start_date, end_date)
    else # has search_term
      @status_count = update_status_count(search_string, join_tables,start_date, end_date)
      query_with_search_term(search_string, join_tables,start_date, end_date)
    end
  end


  def query_with_search_term(search_string, join_tables, start_date, end_date)

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
            .within_timerange(start_date, end_date)
            .where(["#{params[:controller]}.due_date < :today and #{params[:controller]}.status != :status", {today: Time.now.to_date, status: 'Completed'}])
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
              .group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end
    end
  end


  def query_without_search_term(search_string, join_tables, start_date, end_date)
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
            .where(search_string.join(' AND '))
            .order("#{sort_column} #{sort_direction}")
            .group("#{object.table_name}.id")
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)

    when 'Overdue'
      object.joins(join_tables).order("#{sort_column} #{sort_direction}")
                               .where(search_string.join(' AND '))
                               .where(["#{params[:controller]}.due_date < :today and #{params[:controller]}.status != :status", {today: Time.now.to_date, status: 'Completed'}])
                               .limit(params['length'].to_i)
                               .offset(params['start'].to_i)
    else
      object.joins(join_tables)
            .where(status: status)
            .where(search_string.join(' AND '))
            .order("#{sort_column} #{sort_direction}")
            .group("#{object.table_name}.id")
            .limit(params['length'].to_i)
            .offset(params['start'].to_i)
    end
  end


  def query_records_for_risk(search_params, adv_params, join_tables)
    search_string = search_params[:search_string]

    if adv_params[:searchterm_1] == 'severity' || adv_params[:searchterm_1] == 'severity_after'
      if adv_params[:searchterm_1] == 'severity_after'
        sev_text = 'severity_after'
        lik_text = 'likelihood_after'
      else
        sev_text = 'severity'
        lik_text = 'likelihood'
      end
      sev = adv_params[:field_1]
      like = adv_params[:field_2]
    else
      if adv_params[:searchterm_1] == 'likelihood_after'
        sev_text = 'severity_after'
        lik_text = 'likelihood_after'
      else
        sev_text = 'severity'
        lik_text = 'likelihood'
      end
      sev = adv_params[:field_2]
      like = adv_params[:field_1]
    end

    if ['Record', 'Report'].include?(object.name)
      is_admin = @current_user.has_access(object.name.downcase.pluralize, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      full_access_templates = is_admin ? Template.all.map(&:id) : Template.where(name: @current_user.get_all_templates_hash[:full])
      confidential_access_templates = Template.where(name: @current_user.get_all_templates_hash[:confidential])
      viewer_access_templates = is_admin ? Template.all.map(&:id) : Template.where(name: @current_user.get_all_templates_hash[:viewer])

      if object.name == 'Record'
        @status_count = object.joins(join_tables)
                          .order("#{sort_column} #{sort_direction}")
                          .where("(records.templates_id IN (?) AND confidential = false) OR (records.templates_id IN (?) AND viewer_access = true AND confidential = false) OR (records.templates_id IN (?) AND confidential = true)", full_access_templates, viewer_access_templates, confidential_access_templates)
                          .where(search_string.join(' and '))
                          .where("#{object.table_name}.#{sev_text} = ? and #{object.table_name}.#{lik_text} = ?", sev, like)
                          .group("#{object.table_name}.status").count
      else
        reports = Record.preload(:template, :report)
          .where("(records.templates_id IN (?) AND confidential = false) OR (records.templates_id IN (?) AND viewer_access = true AND confidential = false) OR (records.templates_id IN (?) AND confidential = true)",
            full_access_templates, viewer_access_templates, confidential_access_templates)
          .map(&:report).flatten.uniq.compact
        @status_count = object.joins(join_tables)
                          .order("#{sort_column} #{sort_direction}")
                          .where(id: reports.map(&:id))
                          .where(search_string.join(' and '))
                          .where("#{object.table_name}.#{sev_text} = ? and #{object.table_name}.#{lik_text} = ?", sev, like)
                          .group("#{object.table_name}.status").count
      end
    else
      @status_count = object.joins(join_tables)
                        .order("#{sort_column} #{sort_direction}")
                        .where(search_string.join(' and '))
                        .where("#{object.table_name}.#{sev_text} = ? and #{object.table_name}.#{lik_text} = ?", sev, like)
                        .group("#{object.table_name}.status").count
    end

    dashboard_risk_matrix_link_status_counts_update


    if ['Record', 'Report'].include?(object.name)
      is_admin = @current_user.has_access(object.name.downcase.pluralize, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      full_access_templates = is_admin ? Template.all.map(&:id) : Template.where(name: @current_user.get_all_templates_hash[:full])
      confidential_access_templates = Template.where(name: @current_user.get_all_templates_hash[:confidential])
      viewer_access_templates = is_admin ? Template.all.map(&:id) : Template.where(name: @current_user.get_all_templates_hash[:viewer])

      if object.name == 'Record'
        object.joins(join_tables)
          .order("#{sort_column} #{sort_direction}")
          .where("(records.templates_id IN (?) AND confidential = false) OR (records.templates_id IN (?) AND viewer_access = true AND confidential = false) OR (records.templates_id IN (?) AND confidential = true)", full_access_templates, viewer_access_templates, confidential_access_templates)
          .where(search_string.join(' and '))
          .where("#{object.table_name}.#{sev_text} = ? and #{object.table_name}.#{lik_text} = ?", sev, like)
          .limit(params['length'].to_i)
          .offset(params['start'].to_i)
      else
        reports = Record.preload(:template, :report)
          .where("(records.templates_id IN (?) AND confidential = false) OR (records.templates_id IN (?) AND viewer_access = true AND confidential = false) OR (records.templates_id IN (?) AND confidential = true)",
            full_access_templates, viewer_access_templates, confidential_access_templates)
          .map(&:report).flatten.uniq.compact

        object.joins(join_tables)
          .order("#{sort_column} #{sort_direction}")
          .where(id: reports.map(&:id))
          .where(search_string.join(' and '))
          .where("#{object.table_name}.#{sev_text} = ? and #{object.table_name}.#{lik_text} = ?", sev, like)
          .limit(params['length'].to_i)
          .offset(params['start'].to_i)
      end
    else
      object.joins(join_tables)
        .order("#{sort_column} #{sort_direction}")
        .where(search_string.join(' and '))
        .where("#{object.table_name}.#{sev_text} = ? and #{object.table_name}.#{lik_text} = ?", sev, like)
        .limit(params['length'].to_i)
        .offset(params['start'].to_i)
    end
  end


  def dashboard_risk_matrix_link_status_counts_update
    @status_counts = params[:statuses].reduce({}) { |acc, status|
     count = case status
        when 'All'
          if @status_counts['Overdue'].nil?
            @status_count.values.sum
          else
            @status_count.values.sum - @status_count['Overdue'].to_i
          end
        else
          @status_count[status].nil? ? 0 : @status_count[status]
        end

      acc.update(status => count)
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

    @status_count['Overdue'] = object.joins(join_tables)
                                     .within_timerange(start_date, end_date)
                                     .where(search_string.join(' and '))
                                     .group("#{object.table_name}.id")
                                     .select{ |x| x.overdue }.size
    @status_count
  end


  def records_adv_searched
    temp = object.can_be_accessed(@current_user)

    adv_params = params[:advance_search]

    # # risk matrix number from dashboard
    # if (["severity", "likelihood"].include? adv_params["searchterm_1"]) || (["severity", "likelihood"].include? adv_params["searchterm_2"])

    #   field_1 = adv_params["field_1"].to_i
    #   field_2 = adv_params["field_2"].to_i

    #   risk_color = CONFIG::MATRIX_INFO[:risk_table][:rows_color][field_1][field_2]

    #   adv_params["field_1"] = CONFIG::MATRIX_INFO[:risk_definitions][risk_color.to_sym][:rating]
    #   adv_params["searchterm_1"] = "get_risk_classification"

    #   adv_params.delete("field_2")
    #   adv_params.delete("searchterm_2")
    # elsif (["severity_after", "likelihood_after"].include? adv_params["searchterm_1"]) || (["severity_after", "likelihood_after"].include? adv_params["searchterm_2"])

    #   field_1 = adv_params["field_1"].to_i
    #   field_2 = adv_params["field_2"].to_i

    #   risk_color = CONFIG::MATRIX_INFO[:risk_table][:rows_color][field_1][field_2]

    #   adv_params["field_1"] = CONFIG::MATRIX_INFO[:risk_definitions][risk_color.to_sym][:rating]
    #   adv_params["searchterm_1"] = "get_risk_classification_after"

    #   adv_params.delete("field_2")
    #   adv_params.delete("searchterm_2")
    # end

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
          handle_search_date(field[:term], start_date, end_date, temp)
        end
      end
    end

    [start_date.to_datetime, end_date.to_datetime] rescue [nil, nil]
  end

end
