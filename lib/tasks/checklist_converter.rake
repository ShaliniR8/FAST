namespace :checklist_converter do
  logger = Logger.new('log/patch_test.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  desc 'Converts v1 Audit Checklists to v3'
  task :audit_v1_to_v3 => :environment do
    logger.info 'Converting v1 Audit Checklists to v3...'

    # Used for ChecklistHeader and Checklist
    prosafet_admin_id = User.find_by_username('prosafet_admin')[:id]

    logger.info '- Creating 1 new ChecklistHeader...'
    header_id = ChecklistHeader.create(
      title:          'Default',
      description:    'Default Checklist Header',
      status:         'Published',
      created_by_id:  prosafet_admin_id,
    )[:id]

    # add comment to AuditItem.get_headers
    audit_item_headers = AuditItem.get_headers.concat([
      { :field => 'comment', :title => 'Comment' }
    ])

    logger.info "- Creating #{audit_item_headers.length} ChecklistHeaderItems..."
    header_items = audit_item_headers.each.with_index.reduce({}) do |header_items_hash, (header_item, index)|
      # default header item values
      data_type = 'text'
      options = ''
      editable = false

      # Comment, Level of Compliance, and Status are all editable
      # Level of Compliance and Status are dropdowns
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
        display_order:        index,
        checklist_header_id:  header_id,
        title:                header_item[:title],
        data_type:            data_type,
        options:              options,
        editable:             editable,
      )[:id]

      # return a hash with keys of fields from audit_item_headers
      header_items_hash.merge({
        header_item[:field] => { id: header_item_id, options: options }
      })
    end

    # get the ids of Audits with AuditItems
    audit_ids_with_audit_items = Audit.where(
      id: AuditItem.select('distinct owner_id').map(&:owner_id)
    ).map(&:id)
    number_of_new_checklist_rows = AuditItem.where(owner_id: audit_ids_with_audit_items).length

    logger.info "- Creating #{audit_ids_with_audit_items.length} new Checklists..."
    logger.info "- Creating #{number_of_new_checklist_rows} new ChecklistRows..."
    logger.info "- Creating #{number_of_new_checklist_rows * header_items.size} new ChecklistCells..."
    audit_ids_with_audit_items.each do |owner_id|
      # create a Checklist for every Audit with AuditItems
      checklist_id = Checklist.create(
        title:                'Default',
        owner_type:           'Audit',
        owner_id:             owner_id,
        created_by_id:        prosafet_admin_id,
        checklist_header_id:  header_id,
      )[:id]

      AuditItem.where(owner_id: owner_id).each do |audit_item|
        # create a ChecklistRow for each AuditItem
        row_id = ChecklistRow.create(checklist_id: checklist_id)[:id]
        
        header_items.each do |key, header_item|
          options = header_item[:options].present? ? header_item[:options] : nil

          # create a ChecklistCell for each ChecklistHeaderItem
          ChecklistCell.create(
            checklist_row_id:         row_id,
            checklist_header_item_id: header_item[:id],
            options:                  options,
            value:                    audit_item[key.to_sym],
          )
        end
      end
    end

    logger.info '...v1 Audit Checklists successfully converted to v3'
  end
end
