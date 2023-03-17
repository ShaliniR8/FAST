class Field < ActiveRecord::Base

  has_many :record_fields,      :foreign_key => "fields_id",        :class_name => "RecordField"
  has_many :submission_fields,  :foreign_key => "fields_id",        :class_name => "SubmissionField"
  has_many :section_fields,     :foreign_key => "field_id",         :class_name => "SectionField"
  has_many :nested_fields,      :foreign_key => "nested_field_id",  :class_name => "Field", :order => 'field_order ASC'


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


  def export_label_for_asrs
    self.label.tr(' ','_').downcase
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
        options.gsub("\r\n", '').split(";")
      elsif custom_option_id.present?
        CONFIG.custom_options_by_id[custom_option_id].options.split(';') rescue []
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

  def self.get_field_error_msg(key, val)
    error_msg = ""
    if key == :data_type
      values = self.getData_type.map do |a| a[1] end
      unless values.include? val
        error_msg << "Incorrect field type: #{val}\n"
      end
    end
    if key == :display_type
      values = self.getDisplay_type.map do |a| a[1] end
      unless values.include? val
        error_msg << "Incorrect display type: #{val}\n"
      end
    end
    if key == :sabre_map
      unless defined? CONFIG::SABRE_MAPPABLE_FIELD_OPTIONS
        error_msg << "Parameter #{key} does not exist\n"
      end
      unless CONFIG::SABRE_MAPPABLE_FIELD_OPTIONS.values.include? val
        error_msg << "Incorrect sabre map: #{val}\n"
      end
    end
    error_msg
  end

  def self.extract_nested_field(field, nested_field_error, category_id, field_id, options)
    field[:nested_fields].each do |opt_name, field_nested_fields|
      begin
        unless options.split(';').include? opt_name
          nested_field_error << "No option: #{opt_name}\n"
          break
        end
        field_nested_fields.each do |nested_field|
          self.transaction do
            begin
              @nested_field = self.new
              @nested_field.categories_id = category_id
              @nested_field.nested_field_id = field_id
              @nested_field.nested_field_value = opt_name
              nested_field.each do |key__, val__|
                if key__ == :display_type || key__ == :data_type || key__ == :sabre_map
                  nested_field_error << self.get_field_error_msg(key__, val__)
                  unless nested_field_error == ""
                    raise ActiveRecord::Rollback
                  end
                end
                if key__ == :nested_fields
                  nested_field_error << "Nesting not allowed within a nested field\n"
                  raise ActiveRecord::Rollback
                end
                @nested_field[key__] = val__
              end
              @nested_field.save
            rescue
              raise ActiveRecord::Rollback
            end
          end
        end
      rescue
        raise ActiveRecord::Rollback
      end
    end
  end

  def self.extract_field(category, category_id, field_error, nested_field_error)
    category[:Field].each do |field|
      self.transaction do
        begin
          @field = self.new
          field.each do |key_, val_|
            if key_ == :nested_fields
              puts "Pass"
            end
            if key_ == :display_type || key_ == :data_type || key_ == :sabre_map
              field_error << self.get_field_error_msg(key_, val_)
              unless field_error == ""
                raise ActiveRecord::Rollback
              end
            end
            @field[key_] = field[key_]
          end
          @field.categories_id = category_id
          @field.save
          # extract nested fields
          Field.extract_nested_field(field, nested_field_error, category_id, @field.id, @field.options)
        rescue
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
