namespace :version_1_0_3 do


  task :risk_matrix_transform => :environment do

    case BaseConfig.airline_code
    when "BOE"
      puts "BOE risk matrix transform"
      matrix_dic = BOE_Config::MATRIX_INFO[:risk_table][:rows]
      risk_dic = BOE_Config::MATRIX_INFO[:risk_table_index]
      [
        'Report',
        'Record',
        'Finding',
        'SmsAction',
        'Investigation',
        'Sra',
        'Hazard',
      ].each do |type|
        Object.const_get(type).all.each do |x|
          severity = x.severity.to_i if x.severity.present?
          likelihood = x.likelihood.to_i if x.likelihood.present?
          risk_factor = risk_dic[matrix_dic[severity][likelihood].to_sym] rescue nil
          x.risk_factor = risk_factor

          severity_after = x.severity_after.to_i if x.severity_after.present?
          likelihood_after = x.likelihood_after.to_i if x.likelihood_after.present?
          risk_factor_after = risk_dic[matrix_dic[severity_after][likelihood_after].to_sym] rescue nil
          x.risk_factor_after = risk_factor_after
          x.save
        end
      end
    when "SCX"
      puts "SCX risk matrix transform"
    when "NAC"
      puts "NAC risk matrix transform"
      matrix_dic = NAC_Config::MATRIX_INFO[:risk_table][:rows]
      risk_dic = NAC_Config::MATRIX_INFO[:risk_table_index]
      [
        'Report',
        'Record',
        'Finding',
        'SmsAction',
        'Investigation',
        'Sra',
        'Hazard',
      ].each do |type|
        Object.const_get(type).all.each do |x|
          severity = x.severity.to_i if x.severity.present?
          likelihood = x.likelihood.to_i if x.likelihood.present?
          risk_factor = risk_dic[matrix_dic[severity][likelihood].to_sym] rescue nil
          x.risk_factor = risk_factor

          severity_after = x.severity_after.to_i if x.severity_after.present?
          likelihood_after = x.likelihood_after.to_i if x.likelihood_after.present?
          risk_factor_after = risk_dic[matrix_dic[severity_after][likelihood_after].to_sym] rescue nil
          x.risk_factor_after = risk_factor_after
          x.save
        end
      end
    else
      puts "No airline specified risk matrix transform."
    end
  end


end

