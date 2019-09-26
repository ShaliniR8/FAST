class Connection < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :child, polymorphic: true

  def self.get(owner, child)
    Connection.find(:first, conditions: ['owner_id= ? AND owner_type= ? AND child_id= ? AND child_type= ?', owner.id, owner.class.name, child.id, child.class.name] )
  end

  def self.get_all
    Connection.where('owner_id= ? AND owner_type= ? AND child_id= ? AND child_type= ?', owner.id, owner.class.name, child.id, child.class.name)
  end
end
