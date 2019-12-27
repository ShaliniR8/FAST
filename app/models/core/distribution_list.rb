class DistributionList < ActiveRecord::Base

#Concerns List

#Associations List
  belongs_to  :created_by, foreign_key: 'created_by_id', class_name: 'User'
  has_many    :distribution_list_connections, dependent: :destroy
  has_many    :users, through: :distribution_list_connections

  def self.get_headers
    [
      {field: :id,              title: 'ID',          type: 'id'        },
      {field: :title,           title: 'Title',       type: 'string'    },
      {field: :description,     title: 'Description', type: 'textarea'  },
      {field: :created_by_id,   title: 'Created By',  type: 'user'      }
    ]
  end

  def get_user_ids
    user_ids = []
    self.distribution_list_connections.each do |connection|
      user_ids << connection.user_id
    end
    return user_ids
  end

end
