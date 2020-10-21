desc 'Clear baseline and mitigated risk ratings everywhere'
task :clear_risk_ratings => :environment do

  RISK_OBJECTS = %w[Record Report Investigation Finding SmsAction Hazard]

  puts "STARTING CLEAR RISK TASK"

  RISK_OBJECTS.each do |obj|
    record = Object.const_get(obj)
    records = record.all
    records.each do |r|
      # baseline risk
      r.severity          = nil
      r.likelihood        = nil
      r.risk_factor       = nil
      # mitigated risk
      r.severity_after    = nil
      r.likelihood_after  = nil
      r.risk_factor_after = nil
      # other risk attributes
      r.severity_extra        = []
      r.probability_extra     = []
      r.mitigated_severity    = []
      r.mitigated_probability = []
    end
    record.transaction do
      records.each(&:save!)
    end
    puts "CLEARED RISK FOR #{record.name.pluralize}"
  end
  puts "FINISHED CLEAR RISK TASK"
end

