class SamlController < ApplicationController
  helper_method :saml_settings

  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    # response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: saml_settings)

    #Validate the SAML Response and check if user exists in system
    # if response.is_valid?
    #   # session[:nameid] = response.nameid
    #   Rails.logger.debug response.nameid
    #   session[:user_id] = User.where(email: response.nameid).first.id
    #   session[:mode]=""
    #   session[:last_active] = Time.now
    #   redirect_to_target_or_default(root_url)
    #   # session[:user_id] = 1 #TODO: Parse response for account email and match with existing account
    #   # session[:privileges] = {} #TODO: Generate list of permissions based on what they provide in the response
    # else
    #   authorize_failure
    # end
  end

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
    # render xml: meta.generate(settings), content_type: 'application/samlmetadata+xml'
    render xml: meta.generate(settings, true)
  end

  def saml_settings
    #Always ask if they have a url that will provide their metadata
    # if they do, you can generate the majority of the settings from the metadata_parser:
    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    settings = idp_metadata_parser.parse_remote('https://syextec0002.suncountry.com/FederationMetadata/2007-06/FederationMetadata.xml')
    # If you can't use that, you will have to manually define values after the ###IdP Info### Tag

    #The current path to ProSafeT:
    sp_url = "#{request.protocol}#{request.host_with_port}"  #'http://198.71.58.173:3002/' #'http://smx.prosafet.com'

    #Route for app to interpret IdP response:
    settings.assertion_consumer_service_url = "#{sp_url}/saml/consume"

    #Route to provide xml metadata file dynamically
    settings.issuer                         = "#{sp_url}/saml/metadata"

    settings.assertion_consumer_logout_service_url = "#{sp_url}/saml/logout"

    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    ###IdP Info###

    #Route to IdP; should be in metadata.xml they provide under <EntityDescriptor ... entityID="|__this__|" />
    # settings.idp_entity_id                  = "https://SYEXTEC0001.suncountry.com/adfs/services/trust"

    #Route to IdP's sign-in; should be in metadata.xml they provide under <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
    # settings.idp_sso_target_url             = "https://syextec0001.suncountry.com/adfs/ls/"

    #Route to IdP's sign-out; should be in metadata.xml they provide under <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="|__this__|" />
    # settings.idp_slo_target_url             = "https://syextec0001.suncountry.com/adfs/ls/"

    # #Specifies the hash fingerprint of the certificate.
    # #It is recommended that you only define the actual certificate below under idp_cert rather than using collision-risk fingerprints
    # settings.idp_cert_fingerprint           = OneLoginAppCertFingerPrint

    # #Specifies the route to the hash algorithm- standard format is sha1, so leave as "http://www.w3.org/2000/09/xmldsig#sha1"
    # settings.idp_cert_fingerprint_algorithm = "http://www.w3.org/2000/09/xmldsig#sha1"

    # #Specifies the formatting of the identifier
    # settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    #In place of the fingerprint, can also provide the whole certificate- the fingerprint is more efficient however.
    #IdP's certificate; should be in metadata.xml
    # settings.idp_cert                       = ''

    #If there are two certificates, then please place them appropriately in the following hash (match signing to signing and encryption to encryption)
    # idp_cert_multi = {
    #   signing:  ['-----BEGIN CERTIFICATE-----
    #   MIIC8DCCAdigAwIBAgIQHXFgSsDwt7JHI7Qtyk1zUjANBgkqhkiG9w0BAQsFADA0MTIwMAYD
    #   VQQDEylBREZTIFNpZ25pbmcgLSBTWUVYVEVDMDAwMS5zdW5jb3VudHJ5LmNvbTAeFw0xNjEw
    #   MTIxNDE3MDBaFw0xOTEwMTIxNDE3MDBaMDQxMjAwBgNVBAMTKUFERlMgU2lnbmluZyAtIFNZ
    #   RVhURUMwMDAxLnN1bmNvdW50cnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
    #   AQEA4tUOjmp4Vfsxbf/u0G/sYXkjQ2edUE3A1BqZSA/LT0TCq4czSQCEwaoZcAL5juwKrtIt
    #   XxX6XeXaXggpAjgjrxpircCRJzsUdNAcbPJtWDP6tE0c6OXBaYgGhoxIZOPhv8Ohh9iyF/k9
    #   EVMazZayz4QgTKBTD254RVxGprmwTd7F1oeiVfigESSViDA5ErN3BRGOppqWZ3c6U4XqNieA
    #   59dle3bFqv0oS0bmoU8dx/RQXNgdHCRXTJBatPs4Q45am1had9IJwzcZXajwDo8kZC+f9usZ
    #   d0bHGd8vC32FZLtcF38nNoV9gwXgdqVEfwd8Cb5GMK3KclyRd8cXTXhCAQIDAQABMA0GCSqG
    #   SIb3DQEBCwUAA4IBAQCY7Dqjv3pHjhqf6TI55t6PWwkXHtBgutsGlZAdekFvKOsKjScspoDA
    #   N5cqV1akRq4v7Zy+ib6wE2uLC+8Ry4jBv1Yo+bSXz+9z4h7MVvXPCQiW30bL/OMi6/XtctLB
    #   HywVNzCcqissN9ymGzsRxXnvUmoiOovbVpDG6MDgBBBsGn1g4KOkdyT83iqqYlLrtjXm/ruA
    #   qjLG8tUlU1NyIhXKzpcFYI9gc3AMDS4vXIOAzW2SBiXzxfIHXFkT8u9RnYQ4dG1uQtMTVGT8
    #   82TkkGgfMvJtJv7zAm4CXk+4qLzoOb+Zl5NoswPfe9GSwGk880uucA6MG5kqPubw6HgJAHLi
    #   -----END CERTIFICATE-----'],
    #   encryption: ['-----BEGIN CERTIFICATE-----
    #   MIIC9jCCAd6gAwIBAgIQKQFFKDf7WJRKo/DuHm/DTzANBgkqhkiG9w0BAQsFADA3MTUwMwYD
    #   VQQDEyxBREZTIEVuY3J5cHRpb24gLSBTWUVYVEVDMDAwMS5zdW5jb3VudHJ5LmNvbTAeFw0x
    #   NjExMjAxNjU3MDFaFw0xOTExMjAxNjU3MDFaMDcxNTAzBgNVBAMTLEFERlMgRW5jcnlwdGlv
    #   biAtIFNZRVhURUMwMDAxLnN1bmNvdW50cnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
    #   MIIBCgKCAQEA3QkCaMeyXDSxiuQ23MeUfLOkuMld9rm39rNaTtZL40Xzjlw55HWP78tYoEIE
    #   qzAxciwTyDVX3RDbhy9cFavT8cifcRNNUx5iF4kFD+KOxrtB3IU3aocHPJNxJxzgF854rDFR
    #   ZFzYwyUxC/rbmgI1HbUDbXVinPbg15iUACZGaReMP77n8mdEWLWzkDnd0Ef4MsBP45m+l8SD
    #   UchORw9R7FpRGZ+VoIEhxwSI7/hdlBQXDpk6TfCEhhwXKt4wjYeLFhqaOfaPXREpXzdM0u1i
    #   CE24OREHC/zcB1SuGK8aANAm2gYQ47N1XWXbIDP3cFwCIPXVo1L6blM7T7AZ+qfg+QIDAQAB
    #   MA0GCSqGSIb3DQEBCwUAA4IBAQC0PdDA8IfcFYcGyOJKniZEsegQP2EORFTA6F1ONGDfB8hJ
    #   WzxGa2072cqtxLljH6baeJqr9rvMQDxYGs99ZjA2z5Uv2mSSu70aJo40DAdhfaPWUpoetQMw
    #   IHBr83l1+JFGgK973JjvEDHpanupkgAC8oWuMdAZDmt9eF8jAdR468MTxY+ySb6b+nMcUet8
    #   jNWJgOQyOxGVdSz3ixGaev8Q3b1Fzr41xgS+t7TClUUwlSOOiRBr0e37nWlq6BbgwrsHC9A1
    #   xUm1AVJ4Hl9/CqaSpV95RGQFyA5dDEDyHZ+Uk7qtg2Z6Xluqowhc3mpPaBNY3jzO8pSkqPkI
    #   JcAE5s1p
    #   -----END CERTIFICATE-----']
    # }

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

    Rails.logger.debug settings.inspect

    settings
  end
end
