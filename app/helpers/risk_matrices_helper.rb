module RiskMatricesHelper

  def create_risk_matrices_with_num_of_occurrences
    case session[:mode]
    when 'ASAP' # Safety Reporting Module
      create_asap_risk_matrices
      @matrix_title = "#{I18n.t("core.risk.baseline.title")} Risk Analysis: Reports"
      @after_title = "#{I18n.t("core.risk.mitigated.title")} Risk Analysis: Reports"
    when 'SMS'  # Safety Assurance Module
      create_sms_risk_matrices
      @matrix_title="#{I18n.t("core.risk.baseline.title")} Risk Analysis: Findings"
      @after_title="#{I18n.t("core.risk.mitigated.title")} Risk Analysis: Findings"
    when 'SRM'  # Safety Risk Management Module
      create_srm_risk_matrices
      @matrix_title = "#{I18n.t("core.risk.baseline.title")} Risk Analysis: Hazards"
      @after_title = "#{I18n.t("core.risk.mitigated.title")} Risk Analysis: Hazards"
    end
  end


  def create_asap_risk_matrices
     @record_matrix,  @record_after_matrix =
      create_risk_matrix_with_num_of_occurrences(object: 'Record')

    @report_matrix, @report_after_matrix =
      create_risk_matrix_with_num_of_occurrences(object: 'Report')
  end


  def create_sms_risk_matrices
    @finding_matrix, @finding_after_matrix =
      create_risk_matrix_with_num_of_occurrences(object: 'Finding')

    @inv_matrix, @inv_after_matrix =
      create_risk_matrix_with_num_of_occurrences(object: 'Investigation')

    @car_matrix, @car_after_matrix =
      create_risk_matrix_with_num_of_occurrences(object: 'SmsAction')
  end


  def create_srm_risk_matrices
    @hazard_matrix, @hazard_after_matrix =
      create_risk_matrix_with_num_of_occurrences(object: 'Hazard')

    @sra_matrix, @sra_after_matrix =
      create_risk_matrix_with_num_of_occurrences(object: 'Sra')
  end

  # TODO REFACTOR!
  def is_row_probability?
    CONFIG::MATRIX_INFO[:risk_table][:row_header_name] == 'PROBABILITY'
  end

  def get_option_for_orientation(table_type:)
    case CONFIG::MATRIX_INFO[table_type][:orientation]
    when :vertical
      {
        header: :column_header,
        access_order: ['column', 'row']
      }
    when :horizontal
      {
        header: :row_header,
        access_order: ['row', 'column']
      }
    end
  end


  def create_risk_matrix_with_num_of_occurrences(object:)
    row = @risk_table[:row_header]
    col = @risk_table[:column_header]

    temp_matrix = Array.new(row.size){Array.new(col.size, 0)}
    temp_after_matrix = Array.new(row.size){Array.new(col.size, 0)}

    items = case object
    when 'Record'
      Record.can_be_accessed(current_user)
            .within_timerange(@start_date, @end_date)
            .by_emp_groups(params[:emp_groups])
    when 'Hazard', 'Sra'
      Object.const_get(object).within_timerange(@start_date, @end_date)
                              .by_departments(params[:departments])
    else
      Object.const_get(object).within_timerange(@start_date, @end_date)
    end

    items.each do |item|
      if is_row_probability?
        # row is probability
        if item.severity.present? && item.likelihood_index.present?
          temp_matrix[item.likelihood_index][item.severity.to_i] =
            temp_matrix[item.likelihood_index][item.severity.to_i]+1
        end
        if item.severity_after.present? && item.likelihood_after_index.present?
          temp_after_matrix[item.likelihood_after_index][item.severity_after.to_i] =
            temp_after_matrix[item.likelihood_after_index][item.severity_after.to_i]+1
        end
      else # row is severity
        if item.severity.present? && item.likelihood_index.present?
          temp_matrix[item.severity.to_i][item.likelihood_index] =
            temp_matrix[item.severity.to_i][item.likelihood_index]+1
        end
        if item.severity_after.present? && item.likelihood_after_index.present?
          temp_after_matrix[item.severity_after.to_i][item.likelihood_after_index] =
            temp_after_matrix[item.severity_after.to_i][item.likelihood_after_index]+1
        end
      end
    end

    return temp_matrix, temp_after_matrix
  end

end
