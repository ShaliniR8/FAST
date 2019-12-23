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

  def archive_tree
    self.transaction do
      self.children.each{ |child| child.archive_tree }
      self.update_attribute(:archived, true)
    end
  end

  #Returns a hash of the node and all of its non-archived child nodes
  def form_tree(library=OccurrenceTemplate.where(archived: false))
    {}.tap do |base|
      base[:id] = self.id
      base[:title] = self.title
      base[:type] = self.format
      case self.format.to_sym
      when :section
        nodes = library.select{|node| node.parent_id == self.id }
        base[:options] = nodes.map{ |child| [child.title, child.id] }
        base[:nodes] = nodes.reduce([]) { |acc, child| acc << child.form_tree(library); acc }
      when :selection, :checkbox
        base[:options] = self.options.lines
      else #Boolean box or text; neither needs special options
      end

    end
  end

end
