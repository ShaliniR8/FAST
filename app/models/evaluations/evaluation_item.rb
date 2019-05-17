class EvaluationItem < ChecklistItem
  belongs_to :evaluation,foreign_key:"owner_id",class_name: "Evaluation"
  after_create :find_created_by


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'title',                title: 'Title',               num_cols: 6,  type: 'text',  visible: 'index,form,show', required: false},
      {field: 'department',           title: 'Department',          num_cols: 6,  type: 'text',  visible: 'index,form,show', required: false},
      {field: 'reference_number',     title: 'Reference Number',    num_cols: 6,  type: 'text',  visible: 'index,form,show', required: false},
      {field: 'requirement',          title: 'Requirement',         num_cols: 6,  type: 'text',  visible: 'index,form,show', required: false},
      {field: 'level_of_compliance',  title: 'Level of Compliance', num_cols: 6,  type: 'text',  visible: 'index,form,show', required: false},
      {field: 'status',               title: 'Status',              num_cols: 6,  type: 'text',  visible: 'index,form,show', required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def find_created_by
  end

  def self.get_status
    [
      'New',
      'Open',
      'Completed'
    ]
  end

  def self.get_level_of_compliance
    [
      'Meets Requirements',
      'Unsat',
      'Other'
    ]
  end

end
