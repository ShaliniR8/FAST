class Notice < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user, foreign_key: "users_id",class_name:"User"

  # after_create :create_transaction

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'begin_date',   title: 'Notify Date',        num_cols: 6,  type: 'date',       visible: 'index,form,show', required: true },
      {field: 'create_email', title: 'Send Emails',        num_cols: 2,  type: 'booleanbox', visible: 'index,form,show', required: true },
      {field: 'content',      title: 'Notice Message',     num_cols: 12, type: 'text',       visible: 'index,form,show', required: true },
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_status
    {
      1 => 'Unread',
      2 => 'Read'
    }
  end


  def self.get_category
    {
      1 => 'Notice',
      2 => 'Broadcast'
    }
  end


end
