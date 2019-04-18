class AuditRecurrence < Recurrence

  # belongs_to :base, foreign_key: 'owner_id', class_name: 'Audit'

  # has_many :occurrences, foreign_key: 'recurrence_id', class_name: 'Audit'


  # def create_recurring_records
  #   month_offset = month_count[frequency][:number].months
  #   cur_date = anchor_date + month_offset
  #   recurrence_id = base.recurrence_id.present? ? base.recurrence_id : base.id
  #   if base.recurrence_id.blank?
  #     base.recurrence_id = base.id
  #     base.save
  #   end
  #   while cur_date < end_date
  #     audit = base.clone
  #     audit.schedule_date = cur_date
  #     audit.completion = audit.completion + month_offset
  #     audit.recurrence_id = recurrence_id
  #     audit.save
  #     audit.update_uid
  #     base.checklist_records.each do |x|
  #       record = x.clone
  #       record.owner_id = audit.id
  #       record.save
  #     end
  #     cur_date = cur_date + month_count[frequency][:number].months
  #     month_offset = month_offset + month_count[frequency][:number].months
  #   end
  # end

end
