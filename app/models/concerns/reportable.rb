module Reportable
  extend ActiveSupport::Concern
  included do
    has_many :owner_connections, as: :owner, class_name: 'Connection', dependent: :destroy
    has_many :reports, through: :owner_connections, source: :child, source_type: 'Report', conditions: "connections.archive = 0"


    # def connections
    #   Connection.where('(owner_id = :assoc_id AND owner_type = :assoc_type) OR (child_id = :assoc_id AND child_type = :assoc_type)', assoc_type: self.class.name, assoc_id: self.id)
    # end

  end


end

