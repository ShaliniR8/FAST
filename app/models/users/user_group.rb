class UserGroup < ActiveRecord::Base
  serialize :privileges_id

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',           title: 'ID',        num_cols: 4, type: 'text',    visible: 'show',   required: false},
      {field: 'title',        title: 'Title',     num_cols: 4, type: 'text',    visible: 'index',  required: true},
      {field: 'format',       title: 'Format',    num_cols: 2, type: 'text',    visible: 'index',  required: false},
      {field: 'options',      title: 'Options',   num_cols: 6, type: 'textarea',visible: 'index',  required: false}
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

end
