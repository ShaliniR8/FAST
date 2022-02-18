class QueryDatatable
  include ApplicationHelper
  delegate :params, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @ids = params[:ids].present? ? params[:ids].map(&:to_i) : []
    @target = params[:target]
  end


  def as_json(option = {})
    {
      draw: params['draw'].to_i,
      data: data,
      recordsTotal: @ids.size,
      recordsFiltered: @count,
      searchTerms: handle_search[:search_columns_and_terms_map]
    }
  end


  private

  def data
    format_index_column_data(records: records, object_name: object_name)
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


  def object_name
    @target.classify
  end


  def object
    return Object.const_get(@target.classify)
  end


  def records
    search_params = handle_search
    search_string = search_params[:search_string]
    join_tables = prepare_join_tables(search_params)
    query_records_sql(search_string, join_tables)
  end


  def prepare_join_tables(search_params)
    join_tables = columns.select.with_index { |column, index|
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


  def handle_search
    search_columns_and_terms_map = params[:columns].reduce({}) { |acc, (key,value)|
      acc.merge({key => value[:search][:value]})
    }.keep_if { |key,value| value.present? }

    search_string = []
    search_columns_and_terms_map.each do |index, term|
      column = columns[index.to_i]
      column = column.include?('#') ? column.split('#').second : column
      column = column.include?('.') ? column : "#{object.table_name}.#{column}"

      search_string << "#{column} like '%#{term}%'"
    end

    {search_columns_and_terms_map: search_columns_and_terms_map, search_string: search_string}
  end


  def query_records_sql(search_string, join_tables)
    res = []
    @count = 0
    search_string << "#{object.table_name}.id #{@ids.present? ? "IN (#{@ids.join(',')})" : "IS NULL"}"

    if @ids.present?
      res = object.joins(join_tables)
            .where(search_string.join(' and '))

      @count = res.count

      res = res.order("#{sort_column} #{sort_direction}")
               .group("#{object.table_name}.id")
               .limit(params['length'].to_i)
               .offset(params['start'].to_i) if @ids.present?
    end

    res
  end

end
