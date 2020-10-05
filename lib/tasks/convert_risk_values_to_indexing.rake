desc 'Convert Risk Values To Indexing For Airlines That Use Default Risk'
task :convert_risk_values_to_indexing, [:airline_code] => :environment do |task, args|

  AIRLINE_CODE = args.airline_code.upcase
  RISK_OBJECTS = %w[Record Report Investigation Finding SmsAction Hazard]
  RISK_TABLE   = DefaultConfig::MATRIX_INFO[:risk_table]
  ROW_HEADERS  = RISK_TABLE[:row_header]
  COL_HEADERS  = RISK_TABLE[:column_header]

  update_risk  = false

  case AIRLINE_CODE
  when 'BSK'
    update_risk = true
  when 'DEMO'
    update_risk = true
  when 'TMC'
    update_risk = true
  when 'WAA'
    update_risk = true
  when 'TRIAL'
    update_risk = true
  end

  if update_risk
    puts "STARTING CONVERSION TASK"
    RISK_OBJECTS.each do |obj|
      record = Object.const_get(obj)
      records = record.all
      records.each do |r|
        # baseline risk
        if r.severity.present?
          ROW_HEADERS.each_with_index do |h, i|
            r.severity = i if r.severity == h
          end
        end
        if r.likelihood.present?
          COL_HEADERS.each_with_index do |h, i|
            r.likelihood = i if r.likelihood == h
          end
        end
        # mitigated risk
        if r.severity_after.present?
          ROW_HEADERS.each_with_index do |h, i|
            r.severity_after = i if r.severity_after == h
          end
        end
        if r.likelihood_after.present?
          COL_HEADERS.each_with_index do |h, i|
            r.likelihood_after = i if r.likelihood_after == h
          end
        end
      end
      record.transaction do
        records.each(&:save!)
      end
      puts "UPDATED #{record.name.pluralize}"
    end
  end
  puts "FINISHED CONVERSION TASK"
end
