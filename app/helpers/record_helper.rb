module RecordHelper
  def get_category_tag(category)
    category.title.underscore.parameterize("_") rescue 'no_name'
  end


  def get_field_tag(field)
    field.export_label.gsub('&amp;', 'and').gsub(/[^0-9A-Za-z_]/, '')
  end


  def can_send_to_asrs?(record)
    CONFIG::GENERAL[:asrs_integration] &&
    CONFIG::NASA_ASRS[:templates].keys.include?(record.template.name)
  end
end
