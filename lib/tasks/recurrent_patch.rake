namespace :recurring do

  task :patch_current_audits => :environment do
    desc 'Patch existing in progress audits to use Recurrence'

    puts 'BEGIN Patching Audits:'
    num_created = 0
    num_skipped = 0
    audits_in_progress = Audit.where('status != ?', 'Completed')
    puts "Processing #{audits_in_progress.count} active audits:"

    # List of recurrence frequency labels
    month_count_inverted = Hash.new
    Recurrence.month_count.invert.each do |key, value|
      key.each do |key_b, value_b|
        month_count_inverted[value_b] = value
      end
    end

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

    if true
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

        if ['Yearly','Biennial'].include?(frequency) && (audit.template != true)
          puts "Generating template for audit ##{audit.id}..."
          template = audit.clone
          template.template = true
          template.save!

          puts "Generating recurrence for audit ##{audit.id}..."
          recurrence = Recurrence.new
          recurrence.title = audit.title
          recurrence.created_by_id = 1
          recurrence.form_type = "Audit"
          recurrence.template_id = template.id
          recurrence.frequency = frequency
          recurrence.newest_id = audit.id
          recurrence.next_date = audit.completion + month_count
          recurrence.save!

          # Link recurrence_id to the new template
          template.recurrence_id = recurrence.id
          template.save!

          num_created += 1
        else
          puts "Skipping audit ##{audit.id}; Audit is non-recurring."
          num_skipped += 1
        end
      end
    end

    puts "Generated #{num_created} recurring audits."
    puts "Skipped #{num_skipped} non-recurring audits."

    all_audits = Audit.all
    puts "Processing #{all_audits.count} audits:"

    all_audits.group_by(&:title).each do |title, audits|
      # puts "\'#{title}\' -> #{audits.map(&:class).join(', ')}"
      if audits.count > 1
        group_recurrence_id = nil
        audits.each do |audit|
          group_recurrence_id = audit.recurrence_id if audit.template == true
        end
        audits.each do |audit|
          audit.recurrence_id = group_recurrence_id
          audit.save!
        end
      end
    end

    puts "FINISH Patching Audits:"

  end
end
