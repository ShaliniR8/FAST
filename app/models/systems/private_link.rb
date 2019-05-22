class PrivateLink < ActiveRecord::Base


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'name',           title: 'Name',         num_cols: 6,  type: 'text',  visible: 'form,index,show', required: true},
      {field: 'email',          title: 'Email',        num_cols: 6,  type: 'text',  visible: 'form,index,show', required: true},
      {field: 'expire_date',    title: 'Expire Date',  num_cols: 6,  type: 'date',  visible: 'form,index,show', required: true},
      {field: 'access_level',   title: "Access Level", num_cols: 6,  type: 'text',  visible: 'form,index,show', required: true},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


end
