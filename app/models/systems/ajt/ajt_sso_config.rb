class AJTSsoConfig

  SAML_DATA = {
    metadata_link: '',

    response_consume_url: '/saml/consume',
    issuer_metadata_url:  '/saml/metadata',
    issuer_logout_url:    '/saml/logout',

    #This determines the format of the identifying information- for any data format, you can use 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'
    # name_id_format:    'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
    name_id_format:    'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',

    # Location to send SAML request from ProSafeT, should be in the following format:
    # "|__IdP_domain__|/adfs/ls/idpinitiatedsignon"
    access_point: 'https://amerijet.okta.com/app/amerijet_prosafet_1/exkd3uyd1gatW0xJA357/sso/saml',

    # Route to IdP's sign-out; should be in the following format:
    # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
    idp_slo_target_url: 'https://amerijet.okta.com/app/amerijet_prosafet_1/exkd3uyd1gatW0xJA357/sso/saml',


    # Route to IdP; should be in metadata.xml under:
     # <EntityDescriptor ... entityID="|__this__|" />
    idp_entity_id: 'http://www.okta.com/exkd3uyd1gatW0xJA357',

    # Route to IdP's sign-in; should be in metadata.xml under:
     # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
    #idp_sso_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/POST/SSO',
    idp_sso_target_url: 'https://amerijet.okta.com/app/amerijet_prosafet_1/exkd3uyd1gatW0xJA357/sso/saml',

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
      signing_cert:     'MIIDoDCCAoigAwIBAgIGAWm4ONi0MA0GCSqGSIb3DQEBCwUAMIGQMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxETAPBgNVBAMMCGFtZXJpamV0MRwwGgYJKoZIhvcNAQkBFg1p bmZvQG9rdGEuY29tMB4XDTE5MDMyNjA0MTc0N1oXDTI5MDMyNjA0MTg0NlowgZAxCzAJBgNVBAYT AlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2NvMQ0wCwYDVQQK DARPa3RhMRQwEgYDVQQLDAtTU09Qcm92aWRlcjERMA8GA1UEAwwIYW1lcmlqZXQxHDAaBgkqhkiG 9w0BCQEWDWluZm9Ab2t0YS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBglE3 KcDaBV7kccL7OCHNpYzQ0k2hCeAGhBinhR+vJh690gvNoyzjbxrpVpZSX3rdGnf97W/VqGN7Gi7n Fg6B4ZGRi/X/fSvIxVXAjf30FlpC5TpqoQtQULEnthMzE7pEFfCU3q/ClyqGw3OaGPCYZi1Jm35B GV/kF8tbcFj5YWeZyXnDsWkSzLZdJ1huhey8uXhedhA0/H1YAajp7WN7cWQ3MviQQa6GOmXiZuV6 2oOHVedsfoJ9ZEaJBaLI46JuwhJ1OEGWMo4T8ohJ3/NSjvCyeufIaOjKWeskuY+inSRsxZi2e7oY HZhootcABUzG7mHM4YVyR89GNMuoitsTAgMBAAEwDQYJKoZIhvcNAQELBQADggEBACqTk90p9quJ o68grnM4HLFgceyn+GuKBXJYfsrls2ssKjcjl/EpRT58xEaMe9TO7HZWoCR52AStpECvyIuKyc13 v+X4bupjGSoBtXLkx2grQ5IKNs6N9B9+7bxfkTjPd7uvGyxQ9Hs9Q5arGLYvb7+Vvc2r2sinfb7v jQbOTYfuESq3IFg6jfei6erothX9GYm43Djdxdt/T+Woiegt7aoKOUFhgZbfKlafgHWhWUiYghLu bg8zy9PzyQDXq4LyhBuBWNlgrz4scNt0tiXq5vTPZEtFD25RLbGBHPJ0pJ7sSp0F8Ux/UynFuED2 U7EOkH3QPmFLkmPRXf3HJrMEimg=',

      # Certificate used for encrypting the response
      encryption_cert:  'MIIDoDCCAoigAwIBAgIGAWm4ONi0MA0GCSqGSIb3DQEBCwUAMIGQMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxETAPBgNVBAMMCGFtZXJpamV0MRwwGgYJKoZIhvcNAQkBFg1p bmZvQG9rdGEuY29tMB4XDTE5MDMyNjA0MTc0N1oXDTI5MDMyNjA0MTg0NlowgZAxCzAJBgNVBAYT AlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRYwFAYDVQQHDA1TYW4gRnJhbmNpc2NvMQ0wCwYDVQQK DARPa3RhMRQwEgYDVQQLDAtTU09Qcm92aWRlcjERMA8GA1UEAwwIYW1lcmlqZXQxHDAaBgkqhkiG 9w0BCQEWDWluZm9Ab2t0YS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBglE3 KcDaBV7kccL7OCHNpYzQ0k2hCeAGhBinhR+vJh690gvNoyzjbxrpVpZSX3rdGnf97W/VqGN7Gi7n Fg6B4ZGRi/X/fSvIxVXAjf30FlpC5TpqoQtQULEnthMzE7pEFfCU3q/ClyqGw3OaGPCYZi1Jm35B GV/kF8tbcFj5YWeZyXnDsWkSzLZdJ1huhey8uXhedhA0/H1YAajp7WN7cWQ3MviQQa6GOmXiZuV6 2oOHVedsfoJ9ZEaJBaLI46JuwhJ1OEGWMo4T8ohJ3/NSjvCyeufIaOjKWeskuY+inSRsxZi2e7oY HZhootcABUzG7mHM4YVyR89GNMuoitsTAgMBAAEwDQYJKoZIhvcNAQELBQADggEBACqTk90p9quJ o68grnM4HLFgceyn+GuKBXJYfsrls2ssKjcjl/EpRT58xEaMe9TO7HZWoCR52AStpECvyIuKyc13 v+X4bupjGSoBtXLkx2grQ5IKNs6N9B9+7bxfkTjPd7uvGyxQ9Hs9Q5arGLYvb7+Vvc2r2sinfb7v jQbOTYfuESq3IFg6jfei6erothX9GYm43Djdxdt/T+Woiegt7aoKOUFhgZbfKlafgHWhWUiYghLu bg8zy9PzyQDXq4LyhBuBWNlgrz4scNt0tiXq5vTPZEtFD25RLbGBHPJ0pJ7sSp0F8Ux/UynFuED2 U7EOkH3QPmFLkmPRXf3HJrMEimg=',

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
