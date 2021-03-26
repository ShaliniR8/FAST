class SubmissionField < ActiveRecord::Base
  belongs_to :field,            foreign_key: "fields_id",           class_name: "Field"
  belongs_to :submission,       foreign_key: "submissions_id",      class_name: "Submission"

  has_one :category,      :through => :field
  has_many :points, as: :owner, dependent: :destroy,  foreign_key: 'owner_id', class_name: 'Point'

  accepts_nested_attributes_for :points, allow_destroy: true, reject_if: :invalid_point?


  def export
    if self.value.present?
      return "<#{self.category.title.downcase.parameterize}_#{self.field.label.downcase.parameterize}>#{self.value.encode(:xml => :text)}</#{self.category.title.downcase.parameterize}_#{self.field.label.downcase.parameterize}>".html_safe
    else
      nil
    end
  end

  def map_field
    self.field.map_field
  end


  def display_type
    self.field.display_type
  end

  def display_size
    self.field.display_size
  end

  def data_type
    self.field.data_type
  end

  def category
    self.field.category
  end

  def print_value
    (self.display_type == "checkbox" || self.display_type == "radio") ?
      (self.value.split(";").select{|x| x.present?}.join(",  ") rescue '') :
      (self.value.gsub(/\n/, '<br/>').html_safe rescue '')
  end

  def invalid_point?(pt)
    pt[:lat].blank? || pt[:lng].blank?
  end

end
