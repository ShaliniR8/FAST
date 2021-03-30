class DefaultSsoConfig

  # This default SAML data will NOT allow for tests of SSO
   # Please only use this for reference or as a template on how to set up SSO on a new system

  SAML_DATA = {
    # ALWAYS ask if they have a URL for their metadata
    # If they do, you can skip all tags under IdP Info and use the following- otherwise leave this string empty: ''
      metadata_link: 'https://server1.airline_name.com/FederationMetadata/2007-06/FederationMetadata.xml',

    ### IdP Info ###

      # Route to IdP; should be in metadata.xml under:
       # <EntityDescriptor ... entityID="|__this__|" />
      idp_entity_id: 'https://server1.airline_name.com/adfs/services/trust',

      # Route to IdP's sign-in; should be in metadata.xml under:
       # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
      idp_sso_target_url: 'https://server1.airline_name.com/adfs/ls/',


      # Specifies the route to the hash algorithm; standard format is sha1, s"http://www.w3.org/2000/09/xmldsig#sha1"

      ### Fingerprint Config ###

        # Fingerprint is less safe than the full certificate- only set to true and provide settings if needed
        use_fingerprint: false,

        # Value of fingerprint; should be in metadata.xml
        idp_cert_fingerprint: '',

        # Route to hash algorithm- standard is SHA1, you shouldn't have to alter this:
        idp_cert_fingerprint_algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1',

      ### Certificate Config ###
        # This will be used in place of the fingerprint and is more secure
        # If only on certificate, place it under signing_cert
        # Do NOT include BEGIN-END tags on the certificates

        # Certificate used for signing the response
        signing_cert:     'MIIC8DCCAdigAwIBAgIQHXFgSsDwt7JHI7Qtyk1zUjANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylBREZTIFNpZ25pbmcgLSBTWUVYVEVDMDAwMS5zdW5jb3VudHJ5LmNvbTAeFw0xNjEwMTIxNDE3MDBaFw0xOTEwMTIxNDE3MDBaMDQxMjAwBgNVBAMTKUFERlMgU2lnbmluZyAtIFNZRVhURUMwMDAxLnN1bmNvdW50cnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4tUOjmp4Vfsxbf/u0G/sYXkjQ2edUE3A1BqZSA/LT0TCq4czSQCEwaoZcAL5juwKrtItXxX6XeXaXggpAjgjrxpircCRJzsUdNAcbPJtWDP6tE0c6OXBaYgGhoxIZOPhv8Ohh9iyF/k9EVMazZayz4QgTKBTD254RVxGprmwTd7F1oeiVfigESSViDA5ErN3BRGOppqWZ3c6U4XqNieA59dle3bFqv0oS0bmoU8dx/RQXNgdHCRXTJBatPs4Q45am1had9IJwzcZXajwDo8kZC+f9usZd0bHGd8vC32FZLtcF38nNoV9gwXgdqVEfwd8Cb5GMK3KclyRd8cXTXhCAQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQCY7Dqjv3pHjhqf6TI55t6PWwkXHtBgutsGlZAdekFvKOsKjScspoDAN5cqV1akRq4v7Zy+ib6wE2uLC+8Ry4jBv1Yo+bSXz+9z4h7MVvXPCQiW30bL/OMi6/XtctLBHywVNzCcqissN9ymGzsRxXnvUmoiOovbVpDG6MDgBBBsGn1g4KOkdyT83iqqYlLrtjXm/ruAqjLG8tUlU1NyIhXKzpcFYI9gc3AMDS4vXIOAzW2SBiXzxfIHXFkT8u9RnYQ4dG1uQtMTVGT882TkkGgfMvJtJv7zAm4CXk+4qLzoOb+Zl5NoswPfe9GSwGk880uucA6MG5kqPubw6HgJAHLi',
        # Certificate used for encrypting the response. If this cert is empty in client provided XML file, duplicate and use the signing cert. But this must be present
        encryption_cert:  'MIIC9jCCAd6gAwIBAgIQKQFFKDf7WJRKo/DuHm/DTzANBgkqhkiG9w0BAQsFADA3MTUwMwYDVQQDEyxBREZTIEVuY3J5cHRpb24gLSBTWUVYVEVDMDAwMS5zdW5jb3VudHJ5LmNvbTAeFw0xNjExMjAxNjU3MDFaFw0xOTExMjAxNjU3MDFaMDcxNTAzBgNVBAMTLEFERlMgRW5jcnlwdGlvbiAtIFNZRVhURUMwMDAxLnN1bmNvdW50cnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3QkCaMeyXDSxiuQ23MeUfLOkuMld9rm39rNaTtZL40Xzjlw55HWP78tYoEIEqzAxciwTyDVX3RDbhy9cFavT8cifcRNNUx5iF4kFD+KOxrtB3IU3aocHPJNxJxzgF854rDFRZFzYwyUxC/rbmgI1HbUDbXVinPbg15iUACZGaReMP77n8mdEWLWzkDnd0Ef4MsBP45m+l8SDUchORw9R7FpRGZ+VoIEhxwSI7/hdlBQXDpk6TfCEhhwXKt4wjYeLFhqaOfaPXREpXzdM0u1iCE24OREHC/zcB1SuGK8aANAm2gYQ47N1XWXbIDP3cFwCIPXVo1L6blM7T7AZ+qfg+QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQC0PdDA8IfcFYcGyOJKniZEsegQP2EORFTA6F1ONGDfB8hJWzxGa2072cqtxLljH6baeJqr9rvMQDxYGs99ZjA2z5Uv2mSSu70aJo40DAdhfaPWUpoetQMwIHBr83l1+JFGgK973JjvEDHpanupkgAC8oWuMdAZDmt9eF8jAdR468MTxY+ySb6b+nMcUet8jNWJgOQyOxGVdSz3ixGaev8Q3b1Fzr41xgS+t7TClUUwlSOOiRBr0e37nWlq6BbgwrsHC9A1xUm1AVJ4Hl9/CqaSpV95RGQFyA5dDEDyHZ+Uk7qtg2Z6Xluqowhc3mpPaBNY3jzO8pSkqPkIJcAE5s1p',
    ### END IdP Info ###

    ### Base Access Routes for this implementation ### - You shouldn't have to alter these
      response_consume_url: '/saml/consume',
      issuer_metadata_url:  '/saml/metadata',
      issuer_logout_url:    '/saml/logout',

    ### Data Request information
      #This determines the format of the identifying information- for any data format, you can use 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'
      name_id_format:    'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',

    # Security

    ### Critical IdP links:

      # Location to send SAML request from ProSafeT, should be in the following format:
      # "|__IdP_domain__|/adfs/ls/idpinitiatedsignon"
      access_point: 'https://server1.airline_name.com/adfs/ls/idpinitiatedsignon',

      # Route to IdP's sign-out; should be in the following format:
      # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
      idp_slo_target_url: 'https://server1.airline_name.com/adfs/ls/?wa=wsignout1.0',
  }

  #The following must also be defined for SSO: This interprets the IdP's response info and matches it to an account
  def self.digest_response(response)
    #Unique digest statement to find user-identifying email from IdP:
    Rails.logger.debug "######## SSO IMPLEMENTATION DATA ########\n nameid: #{response.nameid}\n attributes: #{response.attributes.to_h}"
    user = User.where(sso_id: response.nameid).first
    if user.nil?
      Rails.logger.info "SSO ERROR: Could not find user with Email address #{response.nameid}"
    end
    user
  end
end
