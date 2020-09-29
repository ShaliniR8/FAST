class Verification < ActiveRecord::Base

  belongs_to :owner, polymorphic: true
  belongs_to :validator, foreign_key: 'users_id', class_name: 'User'
  serialize :additional_validators

  after_commit lambda {
    transaction_log('Create') if transaction_include_action?(:create)
    transaction_log('Update') if transaction_include_action?(:update)
  }


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'verify_date',      title: 'Verification Date',   num_cols: 6,  type: 'date',            visible: 'index,form,show',     required: true},
      {field: 'detail',           title: 'Verification Detail', num_cols: 12, type: 'textarea',        visible: 'index,form,show',     required: true},
      {field: 'additional_validators', title: 'Validators',     num_cols: 12, type: 'select_multiple', visible: 'index,form,show',     required: true,  options: get_user_list, print_field: 'get_validators_names'},
      {field: 'status',           title: 'Status',              num_cols: 6,  type: 'select',          visible: 'index,show,address',  required: false, options: get_result_options},
      {field: 'address_date',     title: 'Date Addressed',      num_cols: 6,  type: 'date',            visible: 'index,show',          required: false},
      {field: 'address_comment',  title: 'Comment',             num_cols: 12, type: 'textarea',        visible: 'index,show,address',  required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def get_all_validators
    return [self.validator] if self.additional_validators.nil?

    validators = self.additional_validators.map { |validator_id|
      User.find(validator_id)
    }
    # all additional valiators + responsible user(validator)
    (validators + [self.validator]).uniq
  end

  def get_validators_names
    return self.validator.full_name if self.additional_validators.nil?

    validators = self.additional_validators.map { |validator|
      User.find(validator).full_name
    }
    # all additional valiators + responsible user(validator)
    (validators + [self.validator.full_name]).uniq.join(', ')
  end

  def self.get_user_list
    User.all.map { |user| [user.full_name, user.id] }
  end

  def self.get_result_options
    ["New", "Approved", "Rejected"]
  end

  def transaction_log(action)
    Transaction.build_for(
      self.owner,
      "#{action.titleize} Verification",
      session[:user_id],
      self.detail)
  end

end
