namespace :checklist_converter do
  logger = Logger.new('log/patch_test.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  desc 'Converts v1 Audit Checklists to v3'
  task :v1_to_v3 => :environment do
    prosafet_admin_id = User.find_by_username('prosafet_admin')[:id]
    logger.info 'TODO Fill In ChecklistHeader.create data'
    header_id = ChecklistHeader.create(
      title: 'TODO Fill In Checklist Header Title',
      description: 'TODO Fill In Checklist Header Description',
      status: 'Published',
      created_by_id: prosafet_admin_id,
    )[:id]

    header_items = AuditItem.get_headers.concat([
      { :field => 'comment', :title => 'Comment' }
    ]).each.with_index.reduce({}) do |header_items_hash, (header_item, index)|
      data_type = 'text'
      options = ''
      editable = false
      
      case header_item[:field]
      when 'comment'
        editable = true
      when 'level_of_compliance'
        data_type = 'dropdown'
        options = AuditItem.get_level_of_compliance.join(';')
        editable = true
      when 'status'
        data_type = 'dropdown'
        options = AuditItem.get_status.join(';')
        editable = true
      end

      header_item_id = ChecklistHeaderItem.create(
        display_order: index,
        checklist_header_id: header_id,
        title: header_item[:title],
        data_type: data_type,
        options: options,
        editable: editable,
      )[:id]

      header_items_hash.merge({
        header_item[:field] => { id: header_item_id, options: options }
      })
    end

    AuditItem.all.map(&:owner_id).uniq.each do |owner_id|
      checklist_id = Checklist.create(
        title: 'TODO Fill in Checklist Title',
        owner_type: 'ChecklistHeader',
        owner_id: header_id,
        created_by_id: prosafet_admin_id,
        checklist_header_id: header_id,
      )[:id]
      AuditItem.where(owner_id: owner_id).each do |audit_item|
        checklist_row_id = ChecklistRow.create(checklist_id: checklist_id)[:id]
        header_items.each do |key, header_item|
          ChecklistCell.create(
            checklist_row_id: checklist_row_id,
            checklist_header_item_id: header_item[:id],
            options: header_item[:options].present? ? header_item[:options] : nil,
            value: audit_item[key.to_sym],
          )
        end
      end
    end
  end
end
