class SubmissionDatatable < ApplicationDatatable

  private

  def sort_column
    columns =  object.get_meta_fields_keys('index')
    columns[params[:order]['0'][:column].to_i]
  end


  def sort_direction
    params[:order]['0'][:dir] == "desc" ? "desc" : "asc"
  end


  def status
    status = params['status']
  end


  def records_total
    counts = object.can_be_accessed(@current_user).count
    { 'all' => counts }
  end


  def status_counts
    if @status_count.empty?
      # when there is no search
      return records_total
    else
      # when there is a search terms
      { 'all' => @status_count['all'] }
    end
  end


  def records_filtered
    columns =  object.get_meta_fields_keys('index')


    start_date, end_date = records_adv_searched
    if start_date.nil? && end_date.nil?
      start_date = params[:advance_search][:start_date].to_datetime rescue nil
      end_date = params[:advance_search][:end_date].to_datetime rescue nil
    end


    # ex) {"1"=>"New"}
    search_terms_and_columns_map = params[:columns].reduce({}) { |acc, (key,value)|
      acc.merge({key => value[:search][:value]})
    }.keep_if { |key,value| value.present? }


    # ex) ["status like '%New%'"]
    search_string = []
    search_terms_and_columns_map.each do |index, term|
      search_string << "#{columns[index.to_i]} like '%#{term}%'"
    end

    # ex) object.joins(:template).where("templates.name LIKE ?", "%#{'inflight'}%")
    # ex) object.joins(join_tables).where(search_string.join(' or '))
    join_tables = columns.select.with_index { |column, index|
      orderable = column == sort_column
      searchable = search_terms_and_columns_map[index.to_s].present?

      (orderable || searchable) && column.include?('.')
     }
    .map { |x|
      column = x.split('.').first
      column = case column
      when 'templates'
        :template
      else
        column.to_sym
      end
    }

    # If there is no search term
    if search_string.empty? && (start_date.nil? && end_date.nil?)
      case status
      when 'all'
        object.joins(join_tables).order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user).group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      when 'overdue'
        #
      else
        object.joins(join_tables)
              .order("#{sort_column} #{sort_direction}")
              .can_be_accessed(@current_user).group("#{object.table_name}.id")
              .limit(params['length'].to_i)
              .offset(params['start'].to_i)
      end


    # If there are search terms
    else

      if start_date.nil? && end_date.nil?
        @status_count = { 'all' => object.joins(join_tables)
          .where(search_string.join(' and '))
          .can_be_accessed(@current_user)
          .count}
      else
        @status_count = { 'all' => object.joins(join_tables)
          .where(search_string.join(' and '))
          .can_be_accessed(@current_user)
          .within_timerange(start_date, end_date)
          .count}
      end


      case status
      when 'all'

        if start_date.nil? && end_date.nil?
          object.joins(join_tables)
                .where(search_string.join(' and '))
                .order("#{sort_column} #{sort_direction}")
                .can_be_accessed(@current_user).group("#{object.table_name}.id")
                .limit(params['length'].to_i)
                .offset(params['start'].to_i)
        else # date range serach
          object.joins(join_tables)
                .where(search_string.join(' and '))
                .order("#{sort_column} #{sort_direction}")
                .can_be_accessed(@current_user)
                .within_timerange(start_date, end_date).group("#{object.table_name}.id")
                .limit(params['length'].to_i)
                .offset(params['start'].to_i)
        end

      when 'overdue'
        #
      else
        if start_date.nil? && end_date.nil?
          object.joins(join_tables)
                .where(search_string.join(' and '))
                .order("#{sort_column} #{sort_direction}")
                .can_be_accessed(@current_user).group("#{object.table_name}.id")
                .limit(params['length'].to_i)
                .offset(params['start'].to_i)
        else # date range serach
          object.joins(join_tables)
                .where(search_string.join(' and '))
                .order("#{sort_column} #{sort_direction}")
                .can_be_accessed(@current_user)
                .within_timerange(start_date, end_date).group("#{object.table_name}.id")
                .limit(params['length'].to_i)
                .offset(params['start'].to_i)
        end
      end
    end
  end





  # def records_total
  #   object.all.size
  # end


  def data
    format_index_column_data(records: records, object_name: object_name)
  end

end
