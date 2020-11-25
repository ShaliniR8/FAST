desc 'Updates airlines with risk rating values to include these values in risk factors'
task :update_risk_ratings => :environment do
  puts 'UPDATING RISK RATINGS...'

  RISK_OBJECTS    = %w[Record Report Investigation Finding SmsAction Hazard]
  RISK_TABLE      = CONFIG::MATRIX_INFO[:risk_table]
  RISK_TABLE_ROWS = RISK_TABLE[:rows]
  RISK_TABLE_DICT = CONFIG::MATRIX_INFO[:risk_table_dict]

  # airline has risk rating values
  if RISK_TABLE_ROWS.present?
    RISK_OBJECTS.each do |obj|
      record_class = Object.const_get(obj)
      records = record_class.all
      objs = []
      records.each do |r|
        sev = r.severity
        lik = r.likelihood
        if sev.present? && lik.present?
          risk_rating = RISK_TABLE_ROWS[sev.to_i][lik.to_i].to_i
          # base risk factor with rating
          r.risk_factor = RISK_TABLE_DICT[risk_rating]
        end
        sev_aftr = r.severity_after
        lik_aftr = r.likelihood_after
        if sev_aftr.present? && lik_aftr.present?
          risk_rating_aftr = RISK_TABLE_ROWS[sev_aftr.to_i][lik_aftr.to_i].to_i
          # mitigated risk factor with rating
          r.risk_factor_after = RISK_TABLE_DICT[risk_rating_aftr]
        end
        objs << r
      end
      record_class.transaction do
        objs.map(&:save!)
        puts "UPDATED #{record_class.name.pluralize}"
      end
    end
  end
  puts 'DONE'
end
