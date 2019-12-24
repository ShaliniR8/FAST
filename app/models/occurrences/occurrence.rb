class Occurrence < ActiveRecord::Base

  belongs_to :template, class_name: 'OccurrenceTemplate'
  belongs_to :owner, polymorphic: true

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'parent_section', title: 'Form',   num_cols: 4, type: 'text',    visible: 'index',  required: false },
      {field: 'title',          title: 'Title',  num_cols: 4, type: 'text',    visible: 'index',  required: true },
      {field: 'value',          title: 'Value',  num_cols: 6, type: 'textarea',visible: 'index',  required: false }
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def parent_section
    parent_section_helper(template).title
  end
  def parent_section_helper(template)
    return template if template.parent.nil?
    if template.format == 'section'
      return template
    else
      parent_section_helper template.parent
    end
  end



  def title
    self.template.title
  end

end
