# Checklists V3
class ChecklistHeaderItem < ActiveRecord::Base
  default_scope order('display_order ASC')
  belongs_to :checklist_header, foreign_key: :checklist_header_id, class_name: 'ChecklistHeader'


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "title",     title: "Column Name",     num_cols: 12, type: "text",     visible: 'form,show', required: false },
      { field: "size",      title: "Column Size % (Should Total 100)", num_cols: 12, type: "number",   visible: 'form,show', required: false },
      { field: "data_type", title: "Input Type",      num_cols: 12, type: "select",   visible: 'form,show', required: false, options: get_data_types},
      { field: "options",   title: "Options (options split by semicolon)",         num_cols: 12, type: "text",     visible: 'form,show', required: false },
      { field: "editable",  title: "Allow Input",     num_cols: 12, type: "boolean",  visible: 'form,show', required: false },
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_data_types
    {
      "Text"        => "text",
      "Dropdown"    => "dropdown",
      "Radio"       => "radio",
      "Checkboxes"  => "checkboxes",
    }
  end


end
