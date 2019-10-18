namespace :recurring do

  logger = Logger.new('log/patch.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  task :patch_current_audits => :environment do
    desc 'Patch existing in progress audits to use Recurrence'

    logger.info 'BEGIN Patching Audits'
    num_created = 0
    num_skipped = 0

    audits_in_progress = Audit.where('status != ?', 'Completed')
    logger.info "Processing #{audits_in_progress.count} active audits."

    # List of recurrence frequency labels
    month_count_inverted = Recurrence.month_count.reduce({}){ |acc,(k,val)| (acc[val[:number]]=k); acc }

    # List of potential user defined audit types in db
    annual_audit_types = ['Annual']
    biennial_audit_types = [
      'Biennial',
      'biennial',
      'Biennial ',
      'biennial ',
      'Parts Biennial',
      'Parts Biennialy',
      'Biennialy',
      'Biennially',
      'biennially',
      'BIENNUALLY',
      'Bi-ennial'
    ]

    audits_in_progress.each do |audit|
      audit_type = audit.audit_type

      # Find audit frequency
      if annual_audit_types.include?(audit_type)
        month_count = 12.months
        frequency = month_count_inverted[12]
      elsif biennial_audit_types.include?(audit_type)
        month_count = 24.months
        frequency = month_count_inverted[24]
      else
        month_count = 0.months
        frequency = 'None'
      end

      if ['Yearly','Biennial'].include?(frequency) && !audit.template
        template = audit.clone
        template.update_attributes({template: true})

        recurrence = Recurrence.create({
          title:            audit.title,
          created_by_id:    1,
          form_type:        "Audit",
          template_id:      template.id,
          frequency:        frequency,
          newest_id:        audit.id,
          next_date:        audit.completion + month_count
        })

        # Link recurrence_id to the new template
        template.update_attributes({recurrence_id: recurrence.id})

        num_created += 1
      else
        num_skipped += 1
      end
    end

    logger.info "Generated #{num_created} recurring audits."
    logger.info "Skipped #{num_skipped} non-recurring audits."

    all_audits = Audit.all
    logger.info "Processing #{all_audits.count} audits."

    all_audits.group_by(&:title).each do |title, audits|
      if audits.count > 1
        group_recurrence_id = audits.find{ |a| a.template }.recurrence_id rescue nil
          #^Find the first that is the template from the array, then fetch its recurrence_id
        Audit.where(id: audits.map(&:id)).update_all(recurrence_id: group_recurrence_id)
          #^Fetch all that were in our group and update all of their recurrence_ids
      end
    end

    logger.info 'FINISH Patching Audits.'

  end
end
