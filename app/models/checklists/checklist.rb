class Checklist < ActiveRecord::Base

  belongs_to :owner, polymorphic: true
  belongs_to :checklist_header, foreign_key: :checklist_header_id, class_name: "ChecklistHeader"

  has_many :checklist_rows, foreign_key: :checklist_id, dependent: :destroy

  accepts_nested_attributes_for :checklist_rows, allow_destroy: true

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',    title: 'ID',    num_cols: 12,  type: 'text', visible: 'index,show',      required: false},
      {field: 'title', title: 'Title', num_cols: 12,  type: 'text', visible: 'index,form,show', required: true},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

end
