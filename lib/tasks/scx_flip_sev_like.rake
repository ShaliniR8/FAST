desc 'SCX: Flip severity and probability values for baseline and mitigate risk matrix'
task :flip_sev_like => :environment do

  objects = ['Investigation', 'Finding', 'SmsAction', 'Hazard', 'Sra', 'Record', 'Report']

  objects.each do |object|
    Object.const_get(object).all.each do |item|

      if item.likelihood.present? && item.severity.present?
        like = item.severity
        sev  = item.likelihood

        item.update_attributes(likelihood: like, severity: sev)

        p "#{item.class.name} ##{item.id} sev: #{sev}, like: #{like}"
      end

      if item.likelihood_after.present? && item.severity_after.present?
        like_after = item.severity_after
        sev_after  = item.likelihood_after

        item.update_attributes(likelihood_after: like_after, severity_after: sev_after)

        p "#{item.class.name} ##{item.id} sev_after: #{sev_after}, like: #{like_after}"
      end

    end
  end

end
