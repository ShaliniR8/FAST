class ChecklistHeader < ActiveRecord::Base

  belongs_to :created_by, foreign_key: :created_by_id, class_name: "User"

  has_many :checklist_header_items, foreign_key: :checklist_header_id, dependent: :destroy
  has_many :checklists, foreign_key: :checklist_header_id

  accepts_nested_attributes_for :checklist_header_items, reject_if: :all_blank, allow_destroy: true

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      {field: "title",          title: "Title",       num_cols: 10, type: "text",     visible: 'form,index,show',   required: true},
      {field: "created_by_id",  title: "Created By",  num_cols: 12, type: "user",     visible: 'show',              required: false},
      {field: "description",    title: "Description", num_cols: 12, type: "textarea", visible: 'form,index,show',   required: false},
      {field: "status",         title: "Status",      num_cols: 12, type: "text",     visible: 'index,show',        required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def checklist_templates
    checklists.where(:is_template => true)
  end


  def duplicate
    record = self.clone
    record.checklist_header_items << self.checklist_header_items.collect{|c| c.clone}
    record.title = record.title + " -- Copy"
    record.status = 'New'
    record.save
    record
  end


end
