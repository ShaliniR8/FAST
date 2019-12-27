class DistributionListConnection < ActiveRecord::Base

#Concerns List

#Associations List
  belongs_to  :distribution_list
  belongs_to  :user

  def self.get_headers
    [
      {field: :id,                    title: 'ID'                   },
      {field: :user_id,               title: 'User ID'              },
      {field: :distribution_list_id,  title: 'Distribution List ID' },
    ]
  end

end
