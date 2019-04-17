class ChecklistHeaderItem < ActiveRecord::Base

  belongs_to :checklist_header, foreign_key: :checklist_header_id, class_name: "ChecklistHeader"


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "title",       title: "Column Name",             num_cols: 12, type: "text",     visible: 'form,show',   required: false },
      { field: "data_type",   title: "Input Type",              num_cols: 12, type: "select",   visible: 'form,show',   required: false, options: get_data_types},
      { field: "options",     title: "Options",                 num_cols: 12, type: "text",     visible: 'form,show',   required: false },
      { field: "editable",    title: "Allow Assignee Input?",   num_cols: 12, type: "boolean",  visible: 'form,show',   required: false },
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_data_types
    {
      "Text"      => "text",
      "Dropdown"  => "dropdown",
      "Radio"     => "radio",
    }
  end


end
