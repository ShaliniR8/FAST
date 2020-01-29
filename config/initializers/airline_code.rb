unless Object.const_defined? 'AIRLINE_CODE'
  AIRLINE_CODE ||= YAML.load_file("#{::Rails.root}/config/airline_code.yml")
end

I18n.default_locale = AIRLINE_CODE.to_sym || :default
I18n.locale = AIRLINE_CODE.to_sym || :default

# unless Object.const_defined? 'CONFIG'
#   CONFIG ||= Object.const_get("#{AIRLINE_CODE}Config")
# end

# unless Object.const_defined? 'CONFIG_IM'
#   CONFIG_IM ||= Object.const_get("#{AIRLINE_CODE}ImplementationManagementConfig") rescue DefaultImplementationManagementConfig
# end

# unless Object.const_defined? 'CONFIG_SA'
#   CONFIG_SA ||= Object.const_get("#{AIRLINE_CODE}SafetyAssuranceConfig") rescue DefaultSafetyAssuranceConfig
# end

# unless Object.const_defined? 'CONFIG_SRM'
#   CONFIG_SRM ||= Object.const_get("#{AIRLINE_CODE}SafetyRiskManagementConfig") rescue DefaultSafetyRiskManagementConfig
# end

# unless Object.const_defined? 'CONFIG_SR'
#   CONFIG_SR ||= Object.const_get("#{AIRLINE_CODE}SafetyReportingConfig") rescue DefaultSafetyReportingConfig
# end
