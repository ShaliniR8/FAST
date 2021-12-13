# Checklists V3
class ChecklistCell < ActiveRecord::Base
  default_scope joins(:checklist_header_item).order('checklist_header_items.display_order ASC')
  belongs_to :checklist_row, foreign_key: :checklist_row_id, class_name: "ChecklistRow"
  belongs_to :checklist_header_item, foreign_key: :checklist_header_item_id, class_name: "ChecklistHeaderItem"

  after_save :delete_cached_fragments


  def readonly?
    false
  end


  def delete_cached_fragments
    edit_fragment_name = "edit_checklist_cell_#{id}"
    show_fragment_name = "show_checklist_cell_#{id}"
    show_panel_fragment_name = "show_panel_checklist_cell_#{id}"
    address_fragment_name = "address_checklist_cell_#{id}"
    address_raw_fragment_name = "address_raw_checklist_cell_#{id}"

    ActionController::Base.new.expire_fragment(edit_fragment_name)
    ActionController::Base.new.expire_fragment(show_fragment_name)
    ActionController::Base.new.expire_fragment(show_panel_fragment_name)
    ActionController::Base.new.expire_fragment(address_fragment_name)
    ActionController::Base.new.expire_fragment(address_raw_fragment_name)
  end
end
