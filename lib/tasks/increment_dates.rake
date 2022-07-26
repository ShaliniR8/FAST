desc "Bump date fields by DAYS"
task increment_dates: [:environment] do
  if ENV['DAYS'].blank?
    puts "DAYS argument is missing. USAGE => rake increment_dates DAYS=5"
    next
  end

  days = ENV['DAYS'].to_i
  puts "#{Time.zone.now}: rake increment_dates DAYS=#{days}"

  Rails.application.eager_load!
  ActiveRecord::Base.descendants.each do |klass|
    if !klass.abstract_class? && klass.table_exists?
      klass.columns_hash.each do |col_name, col_obj|
        if col_obj.type.to_s.include?('date')
          puts "  bump #{klass.table_name}##{col_name}"
          klass.unscoped.update_all("#{col_name} = DATE_ADD(#{col_name}, INTERVAL #{days} DAY)")
        end
      end
    end
  end

  puts "#{Time.zone.now}: rake increment_dates DAYS=#{days} \u2713"
end
