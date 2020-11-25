desc 'Update SRA module baseline Risk Factor'
task :update_risk_factor_in_sra => :environment do

  Hazard.all.select{|x| x.risk_factor == ""}.each do |hazard|
    if hazard.likelihood.present? && hazard.severity.present?

      risk_table_def = CONFIG::MATRIX_INFO[:risk_table][:rows]
      risk_table_dic = CONFIG::MATRIX_INFO[:risk_table_dict]

      row_index      = hazard.severity.to_i
      column_index   = hazard.likelihood.to_i

      risk_factor = risk_table_dic[risk_table_def[row_index][column_index].to_sym]

      # SCX severity and likelihood is swapped
      p "#{hazard.id}: sev(#{hazard.likelihood}), like(#{hazard.severity}) >> #{risk_factor}"

      hazard.update_attributes(risk_factor: risk_factor)
    end
  end

end

desc 'Update Safety Assurrance module baseline Risk Factor'
task :update_risk_factor_in_sa => :environment do

  Investigation.all.select{|x| x.risk_factor == ""}.each do |investigation|
    if investigation.likelihood.present? && investigation.severity.present?

      risk_table_def = CONFIG::MATRIX_INFO[:risk_table][:rows]
      risk_table_dic = CONFIG::MATRIX_INFO[:risk_table_dict]

      row_index      = investigation.severity.to_i
      column_index   = investigation.likelihood.to_i

      risk_factor = risk_table_dic[risk_table_def[row_index][column_index].to_sym]

      # SCX severity and likelihood is swapped
      p "#{investigation.id}: sev(#{investigation.likelihood}), like(#{investigation.severity}) >> #{risk_factor}"

      investigation.update_attributes(risk_factor: risk_factor)
    end
  end

  Finding.all.select{|x| x.risk_factor == ""}.each do |fiding|
    if fiding.likelihood.present? && fiding.severity.present?

      risk_table_def = CONFIG::MATRIX_INFO[:risk_table][:rows]
      risk_table_dic = CONFIG::MATRIX_INFO[:risk_table_dict]

      row_index      = fiding.severity.to_i
      column_index   = fiding.likelihood.to_i

      risk_factor = risk_table_dic[risk_table_def[row_index][column_index].to_sym]

      p "#{fiding.id}: sev(#{fiding.likelihood}), like(#{fiding.severity}) >> #{risk_factor}"

      fiding.update_attributes(risk_factor: risk_factor)
    end
  end

  SmsAction.all.select{|x| x.risk_factor == ""}.each do |fiding|
    if fiding.likelihood.present? && fiding.severity.present?

      risk_table_def = CONFIG::MATRIX_INFO[:risk_table][:rows]
      risk_table_dic = CONFIG::MATRIX_INFO[:risk_table_dict]

      row_index      = fiding.severity.to_i
      column_index   = fiding.likelihood.to_i

      risk_factor = risk_table_dic[risk_table_def[row_index][column_index].to_sym]

      p "#{fiding.id}: sev(#{fiding.likelihood}), like(#{fiding.severity}) >> #{risk_factor}"

      fiding.update_attributes(risk_factor: risk_factor)
    end
  end
end
