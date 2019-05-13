class SamlController < ApplicationController
  helper_method :saml_settings

  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: saml_settings)

    # Validate the SAML Response and check if user exists in system
    if response.is_valid?
      user = digest_response response
      session[:user_id] = user.id
      session[:mode]=""
      session[:last_active] = Time.now
      redirect_to_target_or_default(root_url)
    else
      redirect_to access_point
      # authorize_failure
    end
  end

#PLACE IN CONFIG UNDER SSO:
  def digest_response(response)
    #Unique digest statement to find user-identifying email from IdP:
    email = response.attributes[:'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']
    user = User.where(email: email).first
    if user.nil?
      Rails.logger.info "SSO ERROR: Could not find user with Email address #{email}"
      redirect_to access_point
    else
      user
    end
  end

  def access_point
    'https://syextec0002.suncountry.com/adfs/ls/idpinitiatedsignon'
  end
#END PLACE IN CONFIG UNDER SSO

  def logout
    if params[:SAMLRequest]
      return idp_logout_request
    elsif params[:SAMLResponse]
      return process_logout_response
    else
      return sp_logout_request
    end
  end

  def sp_logout_request
    settings = saml_settings

    if settings.idp_slo_target_url.nil?
      Rails.logger.debug 'SLO IdP Endpoint not defined, executing normal logout'
      delete_session #Delete session
    else
      logout_request = OneLogin::RubySaml::Logoutrequest.new()
      session[:transaction_id] = logout_request.uuid
      Rails.logger.debug "New SP SLO for userid ##{session[:user_id]} transactionid: ##{session[:transaction_id]}"

      if settings.name_identifier_value.nil?
        settings.name_identifier_value = session[:user_id]
      end

      relay_state = url_for controller: 'sessions', action: 'new'
      redirect_to(logout_request.create(settings, RelayState: relay_state))
    end
  end

  def process_logout_response
    settings = saml_settings
    if session.has_key? :transaction_id
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse],
          settings,
          matches_request_id: session[:transaction_id])
    else
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
    end
    Rails.logger.debug "LogoutResponse is: #{logout_response.to_s}"
    if !logout_response.validate
      Rails.logger.debug 'The SAML Logout Response Response is invalid'
    else
      Rails.logger.debug "Delete session for ##{session[:user_id]}"
      delete_session #delete session
    end
  end

  def idp_logout_request
    settings = saml_settings
    logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest])
    if !logout_requst.is_valid?
      Rails.logger.debug 'IdP initiated LogoutRequest was not valid!'
    end
    logger.info "IdP initiated Logout for ##{logout_request.name_id}"

    delete_session

    logout_request_id = logout_request.id
    logout_response = OneLogin::RubySaml::SloLogoutResponse.new.create(settings,
        logout_request_id,
        nil,
        RelayState: params[:RelayState])
    redirect_to logout_response
  end

  def metadata
    settings = saml_settings
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(settings, true)
  end

  def saml_settings
    saml_data = Object.const_get("#{BaseConfig.airline_code}_Config")::SAML_DATA
    Rails.logger.debug saml_data
    if saml_data[:metadata_link].present?
      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = idp_metadata_parser.parse_remote(saml_data[:metadata_link])
    else
      settings = OneLogin::RubySaml::Settings.new
      settings.idp_entity_id      = saml_data[:idp_entity_id]
      settings.idp_sso_target_url = saml_data[:idp_sso_target_url]
      settings.idp_slo_target_url = saml_data[:idp_slo_target_url]

      if saml_data[:user_fingerprint]
        settings.idp_cert_fingerprint           = saml_data[:idp_cert_fingerprint]
        settings.idp_cert_fingerprint_algorithm = saml_data[:idp_cert_fingerprint_algorithm]
      else
        if saml_data[:encryption_cert].present?
          settings.idp_cert = saml_data[:signing_cert]
        else
          idp_cert_multi = {
            signing:  ["-----BEGIN CERTIFICATE----- #{saml_data[:signing_cert]} -----END CERTIFICATE-----"],
            encryption: ["-----BEGIN CERTIFICATE----- #{saml_data[:encryption_cert]} -----END CERTIFICATE-----"]
          }
        end
      end
    end

    sp_url = "#{request.protocol}#{request.host_with_port}"
    settings.assertion_consumer_service_url         = "#{sp_url}#{saml_data[:response_consume_url]}"
    settings.issuer                                 = "#{sp_url}#{saml_data[:issuer_metadata_url]}"
    settings.assertion_consumer_logout_service_url  = "#{sp_url}#{saml_data[:issuer_logout_url]}"
    settings.name_identifier_format                 = saml_data[:name_id_format]

    # # Optional for most SAML IdPs
    # settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    # # or as an array
    # settings.authn_context = [
    #   "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
    #   "urn:oasis:names:tc:SAML:2.0:ac:classes:Password"
    # ]

    # Optional bindings (defaults to Redirect for logout POST for acs)
    # settings.single_logout_service_binding      = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
    # settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"

    # Security section- for if we are specifying a private key and signature for our requests from sp
    settings.security[:authn_requests_signed] = false
    settings.security[:logout_requests_signed] = false
    settings.security[:logout_responses_signed] = false
    settings.security[:metadata_signed] = false
    settings.security[:digest_method] = XMLSecurity::Document::SHA1
    settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

    # Rails.logger.debug settings.inspect

    settings
  end
end
