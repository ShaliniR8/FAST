module GroupAccessHandling
  extend ActiveSupport::Concern
  # This set of terms follow the expectations that the including model contains Group Access Controls

  # The model must have the following columns:
  #   privileges

  # Use the following to include these into the model:
  #  include GroupAccessHandling


  included do
    serialize :privileges
    before_create :set_priveleges
  end


  def get_privileges
    self.privileges.present? ? self.privileges : []
  end


  def set_priveleges
    if self.privileges.blank?
      self.privileges=[]
    end
  end


end
