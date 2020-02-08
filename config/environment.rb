# Load the rails application
require File.expand_path('../application', __FILE__)
require 'carrierwave/orm/activerecord'

# Initialize the rails application
PrdgSession::Application.initialize!




unless Object.const_defined? 'CONFIG_IM'
  CONFIG_IM ||= Object.const_get("#{AIRLINE_CODE}ImplementationManagementConfig") rescue DefaultImplementationManagementConfig
end

unless Object.const_defined? 'CONFIG_SA'
  CONFIG_SA ||= Object.const_get("#{AIRLINE_CODE}SafetyAssuranceConfig") rescue DefaultSafetyAssuranceConfig
end

unless Object.const_defined? 'CONFIG_SRM'
  CONFIG_SRM ||= Object.const_get("#{AIRLINE_CODE}SafetyRiskManagementConfig") rescue DefaultSafetyRiskManagementConfig
end

unless Object.const_defined? 'CONFIG_SR'
  CONFIG_SR ||= Object.const_get("#{AIRLINE_CODE}SafetyReportingConfig") rescue DefaultSafetyReportingConfig
end
