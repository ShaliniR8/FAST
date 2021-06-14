class ViewerComment < ActiveRecord::Base
  belongs_to :viewer, foreign_key:"user_id",class_name:"User"
  belongs_to :owner,  polymorphic: true

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'user_id',    title: 'Submitter',    num_cols: 6,   type: 'user',      visible: 'index,show',       required: false},
      {field: 'created_at', title: 'Submit Date',  num_cols: 6,   type: 'datetime',  visible: 'index,show',       required: true},
      {field: 'content',    title: 'Content',      num_cols: 12,  type: 'textarea',  visible: 'index,form,show',  required: true},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_content
    self.content.gsub(/\n/, '<br/>').html_safe rescue ""
  end

  def get_submission_time
    self.created_at.strftime("%Y-%m-%d")
  end

end
