class OccurrenceTemplate < ActiveRecord::Base

  belongs_to :parent,               foreign_key: 'parent_id',               class_name: 'OccurrenceTemplate'
  has_many :children,               foreign_key: 'parent_id',               class_name: 'OccurrenceTemplate'

  # serialize :options, Array

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',           title: 'ID',        num_cols: 4, type: 'text',    visible: 'show',   required: false},
      {field: 'title',        title: 'Title',     num_cols: 4, type: 'text',    visible: 'index',  required: true},
      {field: 'format',       title: 'Format',    num_cols: 2, type: 'text',    visible: 'index',  required: false},
      {field: 'options',      title: 'Options',   num_cols: 6, type: 'textarea',visible: 'index',  required: false}
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def self.get_formats
    {
      section:      'Section',
      selection:    'Drop Down',
      boolean_box:  'Checkbox',
      checkbox:     'Checkboxes',
      text:         'Text'
    }
  end

  def format
    self[:format]
  end

end
