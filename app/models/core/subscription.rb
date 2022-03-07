class Subscription < ActiveRecord::Base

  belongs_to :owner, polymorphic: true
  belongs_to :user, foreign_key: :user_id, class_name: 'User'


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'user_id',      title: 'Subscriber', num_cols: 6,   type: 'user',   visible: 'index,show,form',  required: true},
      {field: 'frequency',    title: 'Frequency',  num_cols: 6,   type: 'select', visible: 'index,form,show',  required: true, options: 'Subscription.frequency_types'},
      {field: 'day',          title: 'Day',        num_cols: 6,   type: 'text',   visible: 'index,form,show',  required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.frequency_types
    {
      1 => 'Daily',
      2 => 'Weekly',
      3 => 'Monthly',
    }
  end


  def make_copy
    subscription = self.clone
    subscription.save
    subscription
  end


end
