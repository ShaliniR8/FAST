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
        .map{|occurrence| occurrence.value.split("\r\n").map(&:strip).map{|value| "#{occurrence.parent_section} > #{occurrence.title} > #{value}"}}
        .flatten
        .join('<br>').html_safe
    end


  end

end
