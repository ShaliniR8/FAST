class Issue < ActiveRecord::Base
  belongs_to :faa_report,     foreign_key: 'faa_report_id',   class_name: 'FaaReport'
  belongs_to :user,           foreign_key: 'user_id',         class_name: 'User'

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'user_id',          title: 'Entered By',        num_cols: 4,    type: 'user',       visible: 'index,show',      required: false},
      {field: 'title',            title: 'Title',             num_cols: 6,    type: 'text',       visible: 'index,form,show', required: true},
      {field: 'start_date',       title: 'Start Date',        num_cols: 6,    type: 'date',       visible: 'index,form,show', required: false},
      {field: 'end_date',         title: 'End Date',          num_cols: 6,    type: 'date',       visible: 'index,form,show', required: false},
      {field: 'safety_issue',     title: 'Safety Issue',      num_cols: 12,   type: 'textarea',   visible: 'index,form,show', required: true},
      {field: 'corrective_action',title: 'Corrective Action', num_cols: 12,   type: 'textarea',   visible: 'index,form,show', required: true},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

end
