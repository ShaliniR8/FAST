module RootCausable
  extend ActiveSupport::Concern

  included do
    has_many :root_causes, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :root_causes


    def get_root_causes
      self.root_causes
        .map{|root_cause| root_cause.get_value}
        .join('<br>').html_safe
    end

    def get_root_causes_full
      self.root_causes
        .map{|root_cause| "#{root_cause.get_category} > #{root_cause.get_value}"}
        .join('<br>').html_safe
    end


  end

end
