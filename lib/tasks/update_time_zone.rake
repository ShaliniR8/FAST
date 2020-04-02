# for FFT & SCX
  time_zone_map = {
    "MST"  => "Mountain Time (US & Canada)",
    "MDT"  => "Mountain Time (US & Canada)",
    "MT"   => "Mountain Time (US & Canada)",
    "PST"  => "Pacific Time (US & Canada)",
    "PDT"  => "Pacific Time (US & Canada)",
    "AKDT" => "Alaska",
    "HST"  => "Hawaii",
    "EST"  => "Eastern Time (US & Canada)",
    "EDT"  => "Eastern Time (US & Canada)",
    "CST"  => "Central Time (US & Canada)",
    "CDT"  => "Central Time (US & Canada)",
    "AST"  => "Atlantic Time (Canada)",
    "UTC"  => "UTC",
    "UT"   => "UTC",
    "Z"    => "UTC",
    "ZULU" => "UTC",
    "GMT"  => "UTC",
    "ACST" => "Adelaide",
    "ACSST"=> "Adelaide",
    "AEST" => "Sydney",
    "AESST"=> "Sydney",
    "EAST" => "Melbourne",
    "AWST" => "Perth",
    "WST"  => "Perth",
    "ACT"  => "Perth",
    "CAST" => "Perth",
    "CADT" => "Perth",
    "IDLW" => "International Date Line West",
    "CAT"  => "Istanbul",
    "CET"  => "Istanbul",
    "CEST" => "Paris",
    "EETDST"=> "Istanbul",
    "WETDST"=> "Amsterdam",
    "CCT"  => "Rangoon",
    "BRT"  => "Brasilia",
    "NZDT" => "Auckland",
    "NZST" => "Auckland",
    "CETDST"=> "Istanbul",
    "IST"  => "New Delhi",

    "Eastern Time (US & Canada)" => "Eastern Time (US & Canada)",
    "Pacific Time (US & Canada)" => "Pacific Time (US & Canada)",
    "Central Time (US & Canada)" => "Central Time (US & Canada)",
    "Mountain Time (US & Canada)" => "Mountain Time (US & Canada)",
    "Alaska" => "Alaska",
  }

desc "Update existing event dates with appropriate Time Zone"
task :update_event_date => :environment do

  p "[info] List all data with time zone"
  p "[info] Local time zone: #{Time.zone.name}"

  elements = ['Submission', 'Record']
  # elements = ['Record']

  elements.each do |element|
    p "[info] ------------------ #{element} -------------------------------"
    time_zones = []

    Object.const_get(element).transaction do

      Object.const_get(element).all.each do |record|
        p ">> (ID: #{record.id}) #{record.description} \| #{record.event_date} \| #{record.event_time_zone}"
        time_zones << record.event_time_zone unless record.event_time_zone.nil? || record.event_time_zone == ''
      end
      time_zones.uniq!
      p time_zones

      print " > Continue...? (y/n): "
      answer = STDIN.gets.strip

      count_event_date_nil = 0
      count_records_id_nil = 0
      log_event_date_nil = []
      log_records_id_nil = []
      if answer == 'y'
        # Case Event Time Zone
        # 1) "Empty"          => use local Time Zone
        # 2) "3-letter-code"  => map the time zone

        Object.const_get(element).all.each do |record|
          if record.event_date.nil?
            count_event_date_nil += 1
            log_event_date_nil << record.id
            next
          end

          time_zone = record.event_time_zone
          event_date = record.event_date

          # 1)
          if time_zone.nil? || time_zone == '' || time_zone == ' '
            event_zone = Time.zone.name
          # 2)
          elsif time_zones.include? time_zone
            event_zone = time_zone_map[time_zone]
          end
          p " >> DEBUG:  \| #{event_zone} \| #{event_date}"
          utc_time = ActiveSupport::TimeZone.new(event_zone).local_to_utc(event_date)
          p "  update > #{record.id} - #{utc_time} \| #{event_zone}"

          if element == 'Submission' && record.records_id.nil? # what happened?
            count_records_id_nil += 1
            log_records_id_nil << record.id
            next
          end
          record.update_attributes(event_date: utc_time, event_time_zone: event_zone)
        end
      end

      p "# of NULL (event_date): #{count_event_date_nil}"
      p "  >> #{log_event_date_nil}"
      p "# of NULL (records_id): #{count_records_id_nil}"
      p "  >> #{log_records_id_nil}"

    end
  end
end
