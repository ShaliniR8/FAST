class FrameworkIm < Im
  has_many :items,foreign_key:"owner_id",class_name:"FrameworkImItem",:dependent=>:destroy
  def self.display_name
    "Framework IM"
  end
end
