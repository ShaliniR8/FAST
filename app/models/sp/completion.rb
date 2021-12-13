class Completion < Sp::SafetyPromotionBase

  belongs_to :owner,         polymorphic: true
  validates  :user_id,       presence: true

  has_one :checklist, as: :owner, dependent: :destroy

  def foreign_key; owner_id end

  def get_user_name
    User.find(user_id).full_name rescue ""
  end

end
