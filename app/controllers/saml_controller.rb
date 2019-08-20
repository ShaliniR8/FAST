class SamlController < ApplicationController
  helper_method :saml_settings
  helper_method :saml_config

  def saml_config
    Object.const_get("#{BaseConfig.airline_code}_Config")
  end

  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings, RelayState: params[:platform]))
  end

  def consume
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: saml_settings)
    if response.is_valid?(collect_errors = true)
      user = saml_config.digest_response response
      if user.nil?
        redirect_to saml_config::SAML_DATA[:access_point]
      else
        session[:user_id] = user.id
        session[:mode]=""
        session[:last_active] = Time.now
        case params[:RelayState]
        when /^mobile/
          oauth2_token = Oauth2Token.new
          oauth2_token.user = current_user
          oauth2_token.client_application = ClientApplication.where(name: 'prosafet_iOS').first
          oauth2_token.save

          @url = "#{params[:RelayState].split('_').drop(1).join('_')}#{oauth2_token[:token]}"

          render :partial => 'deep_link'
        else
          redirect_to_target_or_default(root_url)
        end
      end
    else
      Rails.logger.info "RESPONSE INVALID: #{response.errors}"
      redirect_to saml_config::SAML_DATA[:access_point]
    end
  end

  def logout
    if params[:SAMLRequest]
      Rails.logger.debug "SAMLRequest: idp -> sp"
      return idp_logout_request
    elsif params[:SAMLResponse]
      Rails.logger.debug "SAMLResponse: sp -> idp -> sp"
      return process_logout_response
    else
      Rails.logger.debug "SAMLRequest: sp -> idp"
      return sp_logout_request
    end
  end

  def sp_logout_reques
    settings = saml_settings

    if settings.idp_slo_target_url.nil?
      Rails.logger.debug 'SLO IdP Endpoint not defined, executing normal logout'
      destroy_session
      redirect_to new_session_path
    else
      logout_request = OneLogin::RubySaml::Logoutrequest.new()
      session[:transaction_id] = logout_request.uuid
      Rails.logger.debug "New SP SLO for userid ##{session[:user_id]} transactionid: ##{session[:transaction_id]}"

      if settings.name_identifier_value.nil?
        settings.name_identifier_value = User.find(session[:user_id]).sso_id
      end

      relay_state = url_for controller: 'sessions', action: 'new'
      redirect_to(logout_request.create(settings, RelayState: relay_state))
    end
  end

  def process_logout_response
    settings = saml_settings
    if session.has_key? :transaction_id
      logout_response = OneLogin::RubySaml::Logoutresponse.new(
        params[:SAMLResponse],
        settings,
        matches_request_id: session[:transaction_id]
      )
    else
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
    end
    Rails.logger.debug "LogoutResponse: #{logout_response.to_s}"
    if !logout_response.validate
      Rails.logger.debug 'SAML Logout Response Response is invalid'
    else
      Rails.logger.debug "Delete session for ##{session[:user_id]}"
      destroy_session
    end
  end

  def idp_logout_request
    settings = saml_settings
    logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest])
    if !logout_request.is_valid?
      Rails.logger.debug 'IdP initiated LogoutRequest invalid'
    end
    Rails.logger.info "IdP initiated Logout for ##{logout_request.name_id}"

    destroy_session

    logout_request_id = logout_request.id
    logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(
      settings,
      logout_request_id,
      nil,
      RelayState: params[:RelayState]
    )
    redirect_to logout_response
  end

  def metadata
    settings = saml_settings
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(settings, true)
  end

  def saml_settings
    saml_data = saml_config::SAML_DATA

    if saml_data[:metadata_link].present?
      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = idp_metadata_parser.parse_remote(saml_data[:metadata_link])
      settings.idp_slo_target_url = saml_data[:idp_slo_target_url]
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

    settings.security[:authn_requests_signed] = false
    settings.security[:logout_requests_signed] = false
    settings.security[:logout_responses_signed] = false
    settings.security[:metadata_signed] = false
    settings.security[:digest_method] = XMLSecurity::Document::SHA1
    settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

    settings
  end

  def destroy_session
    session[:user_id] = nil
    session[:simulated_id] = nil
    session[:last_active] = nil
  end
  helper_method :destroy_session

end
