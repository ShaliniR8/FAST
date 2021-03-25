class Field < ActiveRecord::Base

  has_many :record_fields,      :foreign_key => "fields_id",        :class_name => "RecordField"
  has_many :submission_fields,  :foreign_key => "fields_id",        :class_name => "SubmissionField"
  has_many :section_fields,     :foreign_key => "field_id",         :class_name => "SectionField"
  has_many :nested_fields,      :foreign_key => "nested_field_id",  :class_name => "Field"


  belongs_to :category,         :foreign_key => "categories_id",    :class_name => "Category"
  belongs_to :map_field,        :foreign_key => "map_id",           :class_name => "Field"
  belongs_to :parent_field,     :foreign_key => "nested_field_id",  :class_name => "Field"
  belongs_to :custom_option,    :foreign_key => 'custom_option_id', :class_name => 'CustomOption'


  has_many :eccairs_mappings, foreign_key: :field_id, class_name: 'EccairsMapping'
  has_many :eccairs_attributes, :through => :eccairs_mappings
  accepts_nested_attributes_for :eccairs_mappings, reject_if: proc { |attributes| attributes["eccairs_attribute_id"].blank? }


  scope :nested, -> {where('nested_field_id is not null').order(category_order: :asc)}
  scope :non_nested, -> {where('nested_field_id is null').order(category_order: :asc)}
  scope :active, -> {where(deleted: 0).order(field_order: :asc)}


  def export_label
    if self.label.length>20
      result=self.label.split(' ').last(5).join('_').downcase
      result
    else
      result=self.label.tr(' ','_').downcase
      result
    end
  end



  def get_label
    if self.show_label
      if self.display_type == 'checkbox' && self.required
        label = self.label + " (Minimum #{self.max_options})"
      else
        self.label
      end
    else
      nil
    end
  end



  def custom_id
    self.category.id.to_s+"-"+self.id.to_s
  end



  def self.getDisplay_type
    h = Hash.new
    h["Airport Select Field"] = "airport"
    h["Employee Select Field"] = "employee"
    h["Autocomplete Field"] = "datalist"
    h["Text Field"] = "text"
    h["Radio Button"] = "radio"
    h["Drop Down Menu"] = "dropdown"
    h["Check Boxes"] = "checkbox"
    h["Text Area"] = "textarea"
    h["Map Points"] = "map" if CONFIG::GENERAL[:has_gmap].present?
    return h.sort_by{|k, v| k}
  end



  def self.getData_type
    {
      "Text"          => "text",
      "Date"          => "date",
      "Date/Time"     => "datetime",
      # "Numeric (Integer)"=>"int",
      # "Numeric (Decimal)"=>"float",
      # "Y/N"  =>"bool",
      "Time Zone"     => "timezone"
    }.sort_by{|k, v| k}
  end



  def get_size
    case self.data_type
    when 'text'
      'Text : Unlimited'
    when 'date'
      'Date : String : 20'
    when 'datetime'
      'Date/Time : String : 20'
    when 'timezone'
      'Timezone : String : 10'
    when 'int'
      'Integer : 10'
    when 'bool'
      'String : 255'
    else
      'Unknown'
    end
  end



  def self.getDisplay_size
    (1..12).to_a
  end



  def getOptions2()
    if self.data_type=="timezone"
      ["Hawaii", "Alaska", "Pacific Time (US & Canada)", "Arizona", "Mountain Time (US & Canada)", "Central Time (US & Canada)", "Eastern Time (US & Canada)", "Indiana (East)"]
    else
      self.options.split(";")
    end
  end



  def getOptions()
    if self.data_type=="timezone"
      ActiveSupport::TimeZone.all.map(&:name)
    else
      if options.present?
        options.split(";")
      elsif custom_option_id.present?
        CONFIG.custom_options_by_id[custom_option_id].options.split(';')
      else
        []
      end
    end
  end



  def get_html_tag
    "#{self.category.title.downcase.parameterize}_#{self.label.downcase.parameterize}"
  end



  def get_field_data_type
    "#{custom_id}-#{data_type}"
  end


  def allow_nested_fields?
    ['dropdown', 'checkbox', 'datalist', 'radio'].include? display_type
  end
end
