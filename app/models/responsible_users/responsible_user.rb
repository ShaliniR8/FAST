class ResponsibleUser < ActiveRecord::Base


  belongs_to :user,       :foreign_key => "user_id",        :class_name => "User"


  def self.get_headers
    [
      { :title => "User",             :field => "get_user"            },
      { :title => "Instructions",     :field => "get_instructions"    },
      { :title => "Comments",         :field => "get_comments"        },
      { :title => "Status",           :field => "get_status"          },
    ]
  end


  def get_user
    user.full_name
  end

  def get_instructions
    instructions.gsub(/\n/, '<br/>').html_safe
  end

  def get_status
    status
  end

  def get_comments
    comments.gsub(/\n/, '<br/>').html_safe
  end



end
