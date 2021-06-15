desc 'Create data dictionaries for NASA ASRS templates'
task create_data_dictionary_for_asrs: :environment do
  include RecordHelper
  require 'pp'

  data_dictionary = {
    template: '',
    template_name: '',
    tags: {
      reporter_info: {
        employee_number: {
          label:     'Employee number',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        full_name: {
          label:     'Full name',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        email: {
          label:     'Email',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        job_title: {
          label:     'Job title',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        address: {
          label:     'Address',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        city: {
          label:     'City',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        state: {
          label:     'State',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        zipcode: {
          label:     'Zipcode',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        mobile_number: {
          label:     'Mobile number',
          data_type: 'Text',
          options: nil,
          requried: false
        },
        work_phone_number: {
          label:     'Work phone number',
          data_type: 'Text',
          options: nil,
          requried: false
        }
      },
      report_info: {
        event_title: {
          label:     'Event Title',
          data_type: 'Text',
          options: nil,
          requried: true
        },
        event_date: {
          label:     'Event Date',
          data_type: 'Datetime',
          options: nil,
          requried: true
        }
      }
    }
  }

  # get all NASA ASRS templates
  template_names = CONFIG::NASA_ASRS[:templates].keys

  template_names.each do |template_name|

    template = Template.find_by_name(template_name)

    # Fill in Basic Information (template_name, reporter_info, report_info)
    data_dictionary = fill_in_basic_info(data_dictionary, template)

    categories = template.categories.select { |category| not category.deleted }
    categories.each do |category|
      fields = category.fields.select { |field| not field.deleted }
      fields.each do |field|
        # Fill in Field Information
        data_dictionary = fill_in_field_info(data_dictionary, field, category)
      end
    end

    pp data_dictionary
  end

end


def fill_in_basic_info(data_dictionary, template)
  template_code = CONFIG::NASA_ASRS[:templates][template.name.strip]
  template_xml_name = "Airline#{CONFIG::NASA_ASRS[:airline_number]}_#{template_code.upcase}"
  data_dictionary[:template] = template_xml_name
  data_dictionary[:template_name] = template.name
  #TODO: dynamically assigned reporter, report info
  data_dictionary
end


def fill_in_field_info(data_dictionary, field, category)
  # "label": "Full name",
  # "data_type": "String",
  # "options": nil,
  # "requried": true
  field_properties = %i(label data_type options required)

  data_dictionary[:tags][get_category_tag(category).to_sym] = {}.tap do |category_tag|
    field_properties.each do |field_property|
      category_tag[field_property] = field.send(field_property)
    end
    # Format options / data_type
    category_tag[:options] = category_tag[:options].blank? ? nil : category_tag[:options].split(';')
    category_tag[:data_type] = category_tag[:data_type].capitalize
  end
  data_dictionary
end