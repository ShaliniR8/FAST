class AXRSsoConfig

  SAML_DATA = {
    metadata_link: '',

    response_consume_url: '/saml/consume',
    issuer_metadata_url:  '/saml/metadata',
    issuer_logout_url:    '/saml/logout',

    #This determines the format of the identifying information- for any data format, you can use 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'
    # name_id_format:    'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
    name_id_format:    "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",

    # Location to send SAML request from ProSafeT, should be in the following format:
    # "|__IdP_domain__|/adfs/ls/idpinitiatedsignon"
    access_point: 'https://apps.archer.com/app/archeraviation_prosafet_1/exk7t564blmbD7xyd697/sso/saml',

    # Route to IdP's sign-out; should be in the following format:
    # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
    idp_slo_target_url: 'https://apps.archer.com/app/archeraviation_prosafet_1/exk7t564blmbD7xyd697/sso/saml',


    # Route to IdP; should be in metadata.xml under:
     # <EntityDescriptor ... entityID="|__this__|" />
    idp_entity_id: 'http://www.okta.com/exk7t564blmbD7xyd697',

    # Route to IdP's sign-in; should be in metadata.xml under:
     # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
    #idp_sso_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/POST/SSO',
    idp_sso_target_url: 'https://apps.archer.com/app/archeraviation_prosafet_1/exk7t564blmbD7xyd697/sso/saml',

    # Specifies the route to the hash algorithm; standard format is sha1, s"http://www.w3.org/2000/09/xmldsig#sha1"

    ### Fingerprint Config ###

      # Fingerprint is less safe than the full certificate- only set to true and provide settings if needed
      use_fingerprint: false,

      # Value of fingerprint; should be in metadata.xml
      idp_cert_fingerprint: '',

      # Route to hash algorithm- standard is SHA1, you shouldn't have to alter this:
      idp_cert_fingerprint_algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1',
      # idp_cert_fingerprint_algorithm: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
      # idp_cert_fingerprint_algorithm: 'http://www.w3.org/2001/04/xmlenc#sha256',

    ### Certificate Config ###
      # This will be used in place of the fingerprint and is more secure
      # If only on certificate, place it under signing_cert
      # Do NOT include BEGIN-END tags on the certificates

      # Certificate used for signing the response
      signing_cert:     'MIIDrDCCApSgAwIBAgIGAYq0mRYuMA0GCSqGSIb3DQEBCwUAMIGWMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxFzAVBgNVBAMMDmFyY2hlcmF2aWF0aW9uMRwwGgYJKoZIhvcN AQkBFg1pbmZvQG9rdGEuY29tMB4XDTIzMDkyMDIxNTYyNloXDTMzMDkyMDIxNTcyNlowgZYxCzAJ BgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2NvMQ0w CwYDVQQKDARPa3RhMRQwEgYDVQQLDAtTU09Qcm92aWRlcjEXMBUGA1UEAwwOYXJjaGVyYXZpYXRp b24xHDAaBgkqhkiG9w0BCQEWDWluZm9Ab2t0YS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw ggEKAoIBAQCfJWKZP83WaBi/PnQf3ClbpyBzajNUObEUu8G/dVkJggu2jo9D31LFKvUJaGj6B4V+ n/dSue6TD8kbvxNUWYJW7OI0wc1E5Qycv2bMy8YW8Ul7w4Ojv6Q0iWYbo++tw1GsiRTqVadZzrHw E/ijsLx6SgIZeqnQwZCp7Yb2bx8eNutnsk5823b928mfUqxX7wuaCOxsFnZCvjlLoA9DCIEH2LXk 2MUsiOVKtXTVHRu/4QKro6b3gXMgg/mUpV41zvEg4CHJKyjPS+Cao9k2XPhfBAcssM6HcgPsZTtW bDqXAbctqXF0yaerPI3Szx4XzNv6dKkRaF/nLK1SvFZUWamXAgMBAAEwDQYJKoZIhvcNAQELBQAD ggEBAJOiLO0mmiQV6zcP2TsHoy1VThvbdCjUrXtf0m0Qeqn7kpfL+S3bnet4xpfFwUwCz6sstsKD zZcjM/wavJFBk0RmXEtoiRg/ZADnLnd+sjaGKyhpH/RYOonABuV6uWbeIkPU7iBrLjgUPH3oeGOT IfFGU/Cigy1hUCIfnZLk3dbKEnZd2zNrzBLYKyFut+pVbx7Jpe8YhS96X59QLvin5FgmU19syn3Z YbisZxI/JIBADuGyZBdYUhn4a8PKaI32/5h6Rt5qUoGzXfgh2fDxWGeClrracYY8zZp4Tr6lKrP0 PmGaZkYG+eTPqL43pzcBDukQbupeO13aQKz/LS9+iBs=',

      # Certificate used for encrypting the response
      encryption_cert:  'MIIDrDCCApSgAwIBAgIGAYq0mRYuMA0GCSqGSIb3DQEBCwUAMIGWMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxFzAVBgNVBAMMDmFyY2hlcmF2aWF0aW9uMRwwGgYJKoZIhvcN AQkBFg1pbmZvQG9rdGEuY29tMB4XDTIzMDkyMDIxNTYyNloXDTMzMDkyMDIxNTcyNlowgZYxCzAJ BgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2NvMQ0w CwYDVQQKDARPa3RhMRQwEgYDVQQLDAtTU09Qcm92aWRlcjEXMBUGA1UEAwwOYXJjaGVyYXZpYXRp b24xHDAaBgkqhkiG9w0BCQEWDWluZm9Ab2t0YS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw ggEKAoIBAQCfJWKZP83WaBi/PnQf3ClbpyBzajNUObEUu8G/dVkJggu2jo9D31LFKvUJaGj6B4V+ n/dSue6TD8kbvxNUWYJW7OI0wc1E5Qycv2bMy8YW8Ul7w4Ojv6Q0iWYbo++tw1GsiRTqVadZzrHw E/ijsLx6SgIZeqnQwZCp7Yb2bx8eNutnsk5823b928mfUqxX7wuaCOxsFnZCvjlLoA9DCIEH2LXk 2MUsiOVKtXTVHRu/4QKro6b3gXMgg/mUpV41zvEg4CHJKyjPS+Cao9k2XPhfBAcssM6HcgPsZTtW bDqXAbctqXF0yaerPI3Szx4XzNv6dKkRaF/nLK1SvFZUWamXAgMBAAEwDQYJKoZIhvcNAQELBQAD ggEBAJOiLO0mmiQV6zcP2TsHoy1VThvbdCjUrXtf0m0Qeqn7kpfL+S3bnet4xpfFwUwCz6sstsKD zZcjM/wavJFBk0RmXEtoiRg/ZADnLnd+sjaGKyhpH/RYOonABuV6uWbeIkPU7iBrLjgUPH3oeGOT IfFGU/Cigy1hUCIfnZLk3dbKEnZd2zNrzBLYKyFut+pVbx7Jpe8YhS96X59QLvin5FgmU19syn3Z YbisZxI/JIBADuGyZBdYUhn4a8PKaI32/5h6Rt5qUoGzXfgh2fDxWGeClrracYY8zZp4Tr6lKrP0 PmGaZkYG+eTPqL43pzcBDukQbupeO13aQKz/LS9+iBs=',

  }


  def self.digest_response(response)
    Rails.logger.debug "######## SSO IMPLEMENTATION DATA ########\n nameid: #{response.nameid}\n attributes: #{response.attributes.to_h}"
    user = User.active.where(sso_id: response.nameid).first
    # user = User.active.where(sso_id: response.attributes.to_h["nameid"]).first
    if user.nil?
      Rails.logger.info "SSO ERROR: Could not find user with Employee Number #{response.nameid}"
    end
    user
  end

end
