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

    def has_root_causes?
      root_causes.present?
    end

    def root_cause_lock?
      #Used to indicate whether or not an action should be locked based on Config and root_causes
      CONFIG::GENERAL["#{self.class.name.downcase}_root_cause_lock".to_sym] && !self.has_root_causes? rescue false
    end

  end

end
