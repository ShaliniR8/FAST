class RootCause < ActiveRecord::Base

  belongs_to  :cause_option,        :foreign_key => "cause_option_id",      :class_name => "CauseOption"
  belongs_to  :user,                :foreign_key => "user_id",              :class_name => "User"


  def self.get_headers
    [
      {:field => :get_category,     :title => "Category"},
      {:field => :get_value,        :title => "Value"},
      {:field => :created,          :title => "Created At"},
      {:field => :created_by,       :title => "Created By"},
    ]
  end

  def get_category
    cause_option.get_category
  end

  def get_value
    if cause_option_value.present?
      cause_option_value
    else
      cause_option.name
    end
  end

  def created
    self.created_at.strftime("%Y-%m-%d")
  end

  def created_by
    self.user.full_name
  end

  def get_category_all
    cause_option.get_category_all
  end




end
