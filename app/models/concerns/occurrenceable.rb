module Occurrenceable
  extend ActiveSupport::Concern

  included do
    has_many :occurrences, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :occurrences


    def get_occurrences
      occurrences
        .map{|occurrence| occurrence.value.split("\r\n").map(&:strip)}.flatten
        .join('<br>').html_safe
    end


    def get_occurrences_full
      occurrences
        .map{|occurrence| occurrence.value.split("\r\n")
                          .map(&:strip)
                          .map{|value| "#{occurrence.parent_section} > #{occurrence.title} > #{value}" if value.present?}
                          .compact}
        .flatten
        .join('<br>').html_safe
    end

    def has_occurrences?
      occurrences.present?
    end

    def occurrence_lock?
      #Used to indicate whether or not an action should be locked based on Config and root_causes
      CONFIG::GENERAL["#{self.class.name.downcase}_root_cause_lock".to_sym] && !self.has_occurrences? rescue false
    end

  end

end
