# Checklists V3
class ChecklistRow < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Findingable

  has_many :checklist_cells, foreign_key: :checklist_row_id, dependent: :destroy
  belongs_to :checklist, foreign_key: :checklist_id, class_name: 'Checklist'
  accepts_nested_attributes_for :checklist_cells
  after_save :delete_cached_fragments
  after_destroy :delete_cached_fragments

  def get_cells
    checklist_cells.includes(:checklist_header_item).order('checklist_header_items.display_order')
  end


  def display_findings
    result = ""
    self.findings.each do |finding|
      result += "
        <a style='font-weight:bold' href='/findings/#{finding.id}'>
          ##{finding.id} - #{finding.title}
        </a><br>"
    end
    result.html_safe
  end


  def delete_cached_fragments
    checklist_cells.each do |cell|
      # edit_fragment_name = "edit_checklist_cell_#{cell.id}"
      show_fragment_name = "show_checklist_cell_#{cell.id}"
      show_panel_fragment_name = "show_panel_checklist_cell_#{cell.id}"
      # address_fragment_name = "address_checklist_cell_#{cell.id}"
      # address_raw_fragment_name = "address_raw_checklist_cell_#{cell.id}"

      # ActionController::Base.new.expire_fragment(edit_fragment_name)
      ActionController::Base.new.expire_fragment(show_fragment_name)
      ActionController::Base.new.expire_fragment(show_panel_fragment_name)
      # ActionController::Base.new.expire_fragment(address_fragment_name)
      # ActionController::Base.new.expire_fragment(address_raw_fragment_name)
    end
  end


end
