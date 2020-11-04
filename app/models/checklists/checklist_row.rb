# Checklists V3
class ChecklistRow < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Findingable

  has_many :checklist_cells, foreign_key: :checklist_row_id, dependent: :destroy
  belongs_to :checklist, foreign_key: :checklist_id, class_name: 'Checklist'
  accepts_nested_attributes_for :checklist_cells

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


end
