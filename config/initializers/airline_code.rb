unless Object.const_defined? 'AIRLINE_CODE'
  AIRLINE_CODE ||= YAML.load_file("#{::Rails.root}/config/airline_code.yml")
end
