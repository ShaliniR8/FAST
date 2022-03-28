class ChecklistDatatable
  include ApplicationHelper
  delegate :params, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @checklist = Checklist.find(params[:checklist_id])
  end


  def as_json(option = {})
    {
      draw: params['draw'].to_i,
      data: data,
      recordsTotal: @checklist.checklist_rows.size,
      recordsFiltered: @checklist.checklist_rows.size,
    }
  end

  private

  def data
    checklist_object = {}
    checklist_object[params[:start].to_i] = []

    checklist_row = @checklist.checklist_rows[params[:start].to_i]
    checklist_row.checklist_cells.each do |cell|

      name_value = User.find(cell[:value]).full_name rescue '' if cell.checklist_header_item.data_type == 'employee' || cell.data_type == 'employee'
      options = cell.checklist_header_item.data_type.include?('-custom') ? cell[:custom_options] : cell[:options]
      
      if options.nil? && cell.checklist_header_item.options.present?
        options = cell.checklist_header_item.options
      end

      data_type = cell.data_type
      if data_type.nil?
        data_type = cell.checklist_header_item.data_type  
      end

      checklist_object[params[:start].to_i] << {
        header: cell.checklist_header_item.title,
        value: cell[:value],
        data_type: data_type.gsub('-custom', ''),
        options: options,
        id: cell.id,
        name: name_value,
        allow_input: cell.checklist_header_item.editable
      }
    end

    ## Handle Attachments 
    # attachment_ids   = checklist_row.attachments.map(&:id)
    # attachment_names = checklist_row.attachments.map(&:name)
    # attachment_captions = checklist_row.attachments.map(&:caption)

    # checklist_object[params[:start].to_i] << {
    #   header: 'Attachments',
    #   value: attachment_ids,
    #   data_type: 'attachment',
    #   options: attachment_captions,
    #   id: checklist_row.id,
    #   name: attachment_names,
    #   allow_input: true
    # }

    checklist_object
  end
end