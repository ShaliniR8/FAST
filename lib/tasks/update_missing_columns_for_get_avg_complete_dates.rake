desc '[SA module] Update close_date if complete_date is more up to date'
task :update_close_date_sa => :environment do
  p 'Run update_close_date_sa'
  object_names = %w(SmsAction Finding Investigation Evaluation Inspection Audit)
  object_names.each do |object_name|
    object = Object.const_get(object_name)
    object.transaction do

      items = object.all.select { |x| x.status == 'Completed' &&
                                      x.close_date.present? &&
                                      x.complete_date.present? &&
                                      x.close_date.to_date < x.complete_date }

      items.each do |item|
        p "[info] #{object.name} ##{item.id}"
        p "      close_date: #{item.close_date.to_date}"
        p "      complete_date: #{item.complete_date}"

        item.close_date = item.complete_date
        saved = item.save
        p "[Warning] Failed to update #{object.name} ##{item.id}, #{saved.errors}" unless saved
      end
    end
  end
end

desc '[SRA module] Update close_date if complete_date is more up to date'
task :update_close_date_sra => :environment do
  p 'Run update_close_date_sra'
  object_names = %w(Sra RiskControl)
  object_names.each do |object_name|
    object = Object.const_get(object_name)
    object.transaction do

      items = object.all.select { |x| x.status == 'Completed' &&
                                      x.close_date.present? &&
                                      x.date_complete.present? &&
                                      x.close_date.to_date < x.date_complete }

      items.each do |item|
        p "[info] #{object.name} ##{item.id}"
        p "      close_date: #{item.close_date.to_date}"
        p "      date_complete: #{item.date_complete}"

        item.close_date = item.date_complete
        saved = item.save
        p "[Warning] Failed to update #{object.name} ##{item.id}, #{saved.errors}" unless saved
      end
    end
  end

  items = SafetyPlan.all.select { |x| x.status == 'Completed' &&
                              x.close_date.present? &&
                              x.date_completed.present? &&
                              x.close_date.to_date < x.date_completed }
  items.each do |item|
    p "[info] #{object.name} ##{item.id}"
    p "      close_date: #{item.close_date.to_date}"
    p "      date_complete: #{item.date_completed}"

    item.close_date = item.date_completed
    saved = item.save
    p "[Warning] Failed to update #{object.name} ##{item.id}, #{saved.errors}" unless saved
  end
end

desc 'Update missing created_at column'
task :update_missing_created_at => :environment do
  p 'Run update_missing_created_at'
  object_names = %w(Recommendation SmsAction Finding Investigation Evaluation Inspection Audit)
  object_names.each do |object_name|
    object = Object.const_get(object_name)
    object.transaction do

      items = object.all.select { |x| x.status == 'Completed' && x.created_at.nil? }
      p "====================================================================="
      p "[info] #{object.name}, Total ##{items.size}"
      items.each do |item|

        next if item.open_date.present?

        transaction_log = item.transactions.first

        item.created_at = transaction_log.stamp
        # item.open_date = transaction_log.stamp

        saved = item.save
        p "[Warning] Failed to update #{object.name} ##{item.id}, #{saved.errors}" unless saved

        p "[info] Update #{object.name} ##{item.id}: #{item.created_at.to_date}"
      end
    end
  end

  items = CorrectiveAction.all.select { |x| x.status == 'Completed' && x.created_at.nil? }
  p "====================================================================="
  p "[info] CorrectiveAction, Total ##{items.size}"
  items.each do |item|

    next if item.opened_date.present?

    transaction_log = item.transactions.first

    item.created_at = transaction_log.stamp

    saved = item.save
    p "[Warning] Failed to update CorrectiveAction ##{item.id}, #{saved.errors}" unless saved


    p "[info] Update CorrectiveAction ##{item.id}: #{item.created_at.to_date}"

  end
end

desc 'Update missing close_date'
task :update_missing_close_date => :environment do
  p 'Run update_missing_close_date'
  object_names = %w(Recommendation SmsAction Finding Investigation Evaluation Inspection Audit)
  object_names.each do |object_name|
    object = Object.const_get(object_name)
    object.transaction do

      items = object.all.select { |x| x.status == 'Completed' && x.close_date.nil? }
      p "====================================================================="
      p "[info] #{object.name}, Total ##{items.size}"
      items.each do |item|

        transaction_log = item.transactions.select { |x| (x.content.present?) && x.content.include?('Completed') }.first

        next if transaction_log.nil?

        item.close_date = transaction_log.stamp
        # item.open_date = transaction_log.stamp

        saved = item.save
        p "[Warning] Failed to update #{object.name} ##{item.id}, #{saved.errors}" unless saved

        p "[info] Update #{object.name} ##{item.id}: #{item.close_date.to_date}"
      end
    end
  end
end

# Before run 'rake db:migrate', please run these rake tasks first.
desc 'Update close_date & create_at'
task :update_close_date_and_created_at => :environment do
  Rake::Task['update_close_date_sa'].invoke()
  Rake::Task['update_close_date_sra'].invoke()
  Rake::Task['update_missing_created_at'].invoke()
  Rake::Task['update_missing_close_date'].invoke()
end
