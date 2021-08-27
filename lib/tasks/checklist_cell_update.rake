desc 'Update Checklist Cell Data Types'
task :checklist_cell_update => [:environment] do |t|
  @logger = Logger.new("log/checklist_cell_update.log")

  @logger.info '######################################'
  @logger.info '###### UPDATING CHECKLIST CELLS ######'
  @logger.info '######################################'
  @logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

  editable = ChecklistCell.where(data_type: nil).keep_if{|c| c.checklist_header_item.editable.present?}.count
  edited = 0
  begin
    ChecklistCell.where(data_type: nil).keep_if{|c| c.checklist_header_item.editable.present?}.each do |cell|
      cell.data_type = cell.checklist_header_item.data_type
      cell.save
      edited = edited + 1
    end
  rescue => error
    @logger.info "[ERROR]: #{error.message}"
  end
  @logger.info "Number of Editable Cells Found: #{editable}"
  @logger.info "Number of cells Edited: #{edited}"
  @logger.info '#####################################'
  @logger.info '###### CHECKLIST CELLS UPDATED ######'
  @logger.info '#####################################'
  @logger.info "SERVER DATE+TIME OF CONCLUSION: #{DateTime.now.strftime("%F %R")}\n\n"
end
