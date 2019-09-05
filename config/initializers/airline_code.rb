unless Object.const_defined? 'AIRLINE_CODE'
  AIRLINE_CODE ||= YAML.load_file("#{::Rails.root}/config/airline_code.yml")
end

I18n.default_locale = AIRLINE_CODE.to_sym || :default
I18n.locale = AIRLINE_CODE.to_sym || :default
