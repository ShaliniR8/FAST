class RVFSsoConfig

  SAML_DATA = {
    metadata_link: '',

    response_consume_url: '/saml/consume',
    issuer_metadata_url:  '/saml/metadata',
    issuer_logout_url:    '/saml/logout',

    #This determines the format of the identifying information- for any data format, you can use 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'
    name_id_format:    'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',

    # Location to send SAML request from ProSafeT, should be in the following format:
    # "|__IdP_domain__|/adfs/ls/idpinitiatedsignon"
    access_point: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/Redirect/SSO',

    # Route to IdP's sign-out; should be in the following format:
    # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
    idp_slo_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/Redirect/SSO',


    # Route to IdP; should be in metadata.xml under:
     # <EntityDescriptor ... entityID="|__this__|" />
    idp_entity_id: 'https://523516925-01.id.overwatchid.com/saml/metadata',

    # Route to IdP's sign-in; should be in metadata.xml under:
     # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
    #idp_sso_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/POST/SSO',
    idp_sso_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/Redirect/SSO',

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
      signing_cert:     'MIIFJzCCAw+gAwIBAgIJAIlt1JulAtsHMA0GCSqGSIb3DQEBCwUAMCoxKDAmBgNVBAMMHzUyMzUxNjkyNS0wMS5pZC5vdmVyd2F0Y2hpZC5jb20wHhcNMTgwNDI2MTQxNDMyWhcNMzgwNDIxMTQxNDMyWjAqMSgwJgYDVQQDDB81MjM1MTY5MjUtMDEuaWQub3ZlcndhdGNoaWQuY29tMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtb9fjUOrJM6/fdAilIVMOPEND7j8nA+iPSJbya+sMX0BmJmHZO4aWUcM1QDtToS8KsuWX1eqMScROrGHSJxdKkHSzP9QdcJtF0tQaAkOT1XBWOczKyNtK34s81E5HONDZSp4npiLaW8/ygSu6OgInBdZwyEgHazMZWvglYlE0lO/z2HvpCpMXcnWFWd7fkiRuSRKfOaXsx4qtoIhq9L/01g3jDr4sWuucRbaOvldg42sTN2VW57oOi2PAkU8cZyQAOM/4m0jGFyLqK1yCzK30aNSVmIU7ed8lMSFSNt3jtt+E5vqF9idmNKFnuseYEC63z0z5KzAvzGuGClZgIQ6Wy37MgW6LdLsgRRmp2bqAppDFQOQruEfenPbi17/52veaOWkzcKM+CC9ShA8nRlo01b8VEG6qiQ/uvjdc/9TKSL03AtfQ0C79ueV8op1q/M3aPEtOZBpzvuQ/e+jOlfeq2iWdtbkUasbB0ZB1TWFAlcHVP+6U6HpUW0jN4w9K/QyL0qUdKmffnKmlzam0pRp4gic4o/akMEITMeU+x7uMd65qV4yWXjGoLpyRzXioVka9BXz/AbK+wglqR+m5tT7ItL/DZzAVHfUZmFu8Qo4lq86xQoCWA0xnpEPI9JvpUUJ1fPaDjaMGgzAITWPQ2eAMlFcsqt6tqD4RhyLMdMQTZ0CAwEAAaNQME4wHQYDVR0OBBYEFPQROhbuQWunlK6/0ceyAy0+kwKIMB8GA1UdIwQYMBaAFPQROhbuQWunlK6/0ceyAy0+kwKIMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggIBAFWo4CTJGyC06zBWSHv29Dmuhi4Ni7BbNTOfZaahorOijGZe2yHsFMMOkRJqiu2a3/uM/F1xeokC7Clh7fNokKiyFRSSlimv+VimlMEIeFkD4pg00wxgRLic7L/DDoRqc7bVqf4wN+NxYfI982h/Q3/GF8EnQsNOMOB3v4WnjZVVy+crZxU3MU7dE6q2NGK0WbSOEtRwXwxumaYhGOpxbfKFtdsrUixOfj9lpf6Yo0+LihUm7X6cM3uqQBJ5XZf6Mvh6EGJW6IWmqrSVpFFTP+W+/2qh6qrexMvD6G12IKjzAnR1ZL/4EGRVdU9o6itxD1dXJHe9RBKHrDVaGGChkU/v8SGuP9RXoKI6KZeYbFyuqTpHXCV2GG9kyU5NjBHllRa+4mC+cV/wzW/O45lCAGsA73CUL42GqpdV+DPl6UrionHLDwKO2K2/pGyZoAiW9sz6+QAnAVKdweTaS17V5dPPbG+Tlc3apdNYA7rFflOOwq/UjfBbesc8xokPUmryWFB4OEgGFd9gIshwFe5eO1llxyIWVSENZQtjF1lQCHALiMWJIGewU+AcrAYOloF0WOlCB8Uqow1J65P1Dpy1+y8Kx/+JzAqAKB8HGUI6diV0cuBlj7cC6wkJQU3QGx/Nc9lY1JOUJF9L/XImqfmOGUrAfZdREVIa3aMYWrD3xLtQ',

      # Certificate used for encrypting the response
      encryption_cert:  'MIIC9jCCAd6gAwIBAgIQKQFFKDf7WJRKo/DuHm/DTzANBgkqhkiG9w0BAQsFADA3MTUwMwYDVQQDEyxBREZTIEVuY3J5cHRpb24gLSBTWUVYVEVDMDAwMS5zdW5jb3VudHJ5LmNvbTAeFw0xNjExMjAxNjU3MDFaFw0xOTExMjAxNjU3MDFaMDcxNTAzBgNVBAMTLEFERlMgRW5jcnlwdGlvbiAtIFNZRVhURUMwMDAxLnN1bmNvdW50cnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3QkCaMeyXDSxiuQ23MeUfLOkuMld9rm39rNaTtZL40Xzjlw55HWP78tYoEIEqzAxciwTyDVX3RDbhy9cFavT8cifcRNNUx5iF4kFD+KOxrtB3IU3aocHPJNxJxzgF854rDFRZFzYwyUxC/rbmgI1HbUDbXVinPbg15iUACZGaReMP77n8mdEWLWzkDnd0Ef4MsBP45m+l8SDUchORw9R7FpRGZ+VoIEhxwSI7/hdlBQXDpk6TfCEhhwXKt4wjYeLFhqaOfaPXREpXzdM0u1iCE24OREHC/zcB1SuGK8aANAm2gYQ47N1XWXbIDP3cFwCIPXVo1L6blM7T7AZ+qfg+QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQC0PdDA8IfcFYcGyOJKniZEsegQP2EORFTA6F1ONGDfB8hJWzxGa2072cqtxLljH6baeJqr9rvMQDxYGs99ZjA2z5Uv2mSSu70aJo40DAdhfaPWUpoetQMwIHBr83l1+JFGgK973JjvEDHpanupkgAC8oWuMdAZDmt9eF8jAdR468MTxY+ySb6b+nMcUet8jNWJgOQyOxGVdSz3ixGaev8Q3b1Fzr41xgS+t7TClUUwlSOOiRBr0e37nWlq6BbgwrsHC9A1xUm1AVJ4Hl9/CqaSpV95RGQFyA5dDEDyHZ+Uk7qtg2Z6Xluqowhc3mpPaBNY3jzO8pSkqPkIJcAE5s1p',

  }


  def self.digest_response(response)
    Rails.logger.debug "######## SSO IMPLEMENTATION DATA ########\n nameid: #{response.nameid}\n attributes: #{response.attributes.to_h}"
    user = User.where(sso_id: response.nameid).first
    if user.nil?
      Rails.logger.info "SSO ERROR: Could not find user with Email address #{response.nameid}"
    end
    user
  end

end
