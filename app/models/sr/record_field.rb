class RecordField < ActiveRecord::Base
  belongs_to :field, foreign_key:"fields_id", class_name: "Field"
  belongs_to :record,foreign_key: "records_id",class_name: "Record"
  after_update :create_transaction

  has_many :points, as: :owner, dependent: :destroy,  foreign_key: 'owner_id', class_name: 'Point'
  accepts_nested_attributes_for :points, allow_destroy: true, reject_if: :invalid_point?


  scope :nonempty, where('value <> ?', '')


  def display_type
    self.field.display_type
  end

  def map_field
    self.field.map_field
  end
  def display_size
    self.field.display_size
  end

  def data_type
    self.field.data_type
  end

  def category
    self.field.category rescue nil
  end

  def create_transaction
    #RecordTransaction.create(:users_id=>session[:user_id],:content=>"#{self.field.category.title}-#{self.field.label}",:action=>"Update",:owner_id=>self.record.id,:stamp=>Time.now)
  end

  def print_value
    (self.display_type == "checkbox" || self.display_type == "radio") ?
      (self.value.split(";").select{|x| x.present?}.join(",  ") rescue '') :
      (self.value.gsub(/\n/, '<br/>').html_safe rescue '')
  end


  def get_eccairs_value
    if field.custom_option.present? && field.custom_option.eccairs_mapping.present?
      custom_option = field.custom_option
      custom_option.eccairs_mapping.split(';')[custom_option.options.split(';').find_index(value)]
    else
      value
    end
  end


  def invalid_point?(pt)
    pt[:lat].blank? || pt[:lng].blank?
  end
end
