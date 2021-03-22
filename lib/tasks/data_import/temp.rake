task :temp => :environment do
  @sql = ""

  puts "linking findings to audits"
  Finding.all.each do |finding|
    if finding.audit_obj_id
      matching_audits = Audit.where(obj_id: finding.audit_obj_id)
      if matching_audits.count > 0
         @sql += "update findings set owner_id = #{matching_audits.first.id} where id = #{finding.id};\n"
      else
        puts "Found no matching audits, skipping"
      end
    end
  end

  puts "linking findings to investigations"
  Finding.all.each do |finding|
    if finding.audit_obj_id
      matching_investigations = Investigation.where(obj_id: finding.audit_obj_id)
      if matching_investigations.count > 0
         @sql += "update findings set owner_id = #{matching_investigations.first.id} where id = #{finding.id};\n"
      else
        puts "Found no matching audits, skipping"
      end
    end
  end

  File.write("./lib/tasks/temp.sql", @sql)
  puts "'mysql -u admin -p prosafet_fft_dev_db < lib/tasks/temp.sql'"
  puts "This may take some time"
  %x`mysql -u admin -p prosafet_fft_dev_db < lib/tasks/temp.sql`
end
