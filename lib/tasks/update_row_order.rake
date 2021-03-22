task update_row_order: :environment do
  Checklist.all.each do |checklist|
    count = 1
    checklist.checklist_rows.order(:id).each do |checklist_row|
      checklist_row.row_order = count
      count += 1
      checklist_row.save
    end
  end
end