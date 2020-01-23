class Notice < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :user, foreign_key: "users_id",class_name:"User"

  # after_create :create_transaction

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'content',      title: 'Message',     num_cols: 12, type: 'text',       visible: 'index,form,show', required: true },
      {field: 'begin_date',   title: 'Date',        num_cols: 6,  type: 'date',       visible: 'index,form,show', required: true },
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
      1 => {title: 'Notice',      icon: nil, style: nil},
      2 => {title: 'Broadcast',   icon: nil, style: 'color:steelblue;font-weight:bold'},
      3 => {title: 'Annoucement', icon: 'bullhorn', style: 'color:teal;font-weight:bold'}
    }
  end


end
