task :checklist_migrate => :environment do
    p 'Run checklist existing data migrate'
    ims = Im.all
    ims.each do |im|
        user = User.where(username: 'prosafet_admin')
        checklist_items = ChecklistItem.where(owner_id: im.id)
        checklist_header = ChecklistHeader.where(title: 'SMS IM Default Header')
        checklist_header_items = ChecklistHeaderItem.where(checklist_header_id: checklist_header[0].id)

        checklist = Checklist.new(title: 'SMS IM Default Template', owner_type: 'Im', owner_id: im.id, created_by_id: user[0].id, checklist_header_id: checklist_header[0].id)
        checklist.save!

        checklist_items.each do |item|
            checklist = Checklist.last
            checklist_row = ChecklistRow.new(checklist_id: checklist.id, created_by_id: user[0].id, is_header: 0)
            checklist_row.save!

            checklist_row = ChecklistRow.last
            checklist_header_items.each do |header_item|
                header_item_title = header_item.title.downcase
                if header_item_title.include? ' '
                    header_item_title = header_item_title.gsub! ' ', '_'
                end
                if header_item_title.include? 'level_of_compliance'
                    checklist_cell = ChecklistCell.new(checklist_row_id: checklist_row.id, checklist_header_item_id: header_item.id, value: item[header_item_title], options: 'None;Planned;Implemented', data_type: 'dropdown')
                elsif header_item_title.include? 'status'
                    checklist_cell = ChecklistCell.new(checklist_row_id: checklist_row.id, checklist_header_item_id: header_item.id, value: item[header_item_title], options: 'New;Open;Completed', data_type: 'dropdown')
                else
                    checklist_cell = ChecklistCell.new(checklist_row_id: checklist_row.id, checklist_header_item_id: header_item.id, value: item[header_item_title])
                end
                checklist_cell.save!
            end

            packages = Package.where(owner_id: item.id)
            packages.each do |package|
                package.update_attributes(owner_id: checklist_row.id)
            end
        end
    end
end