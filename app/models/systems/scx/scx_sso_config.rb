class SCXSsoConfig

  SAML_DATA = {
    metadata_link: '',

    response_consume_url: '/saml/consume',
    issuer_metadata_url:  '/saml/metadata',
    issuer_logout_url:    '/saml/logout',

    #This determines the format of the identifying information- for any data format, you can use 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'
    # name_id_format:    'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
    name_id_format:    'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
    # name_id_format:    'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',

    # Location to send SAML request from ProSafeT, should be in the following format:
    # "|__IdP_domain__|/adfs/ls/idpinitiatedsignon"
    access_point: 'https://suncountry.okta.com/app/suncountry_prosafet_1/exktiwa7r8Jnln8jT696/sso/saml',

    # Route to IdP's sign-out; should be in the following format:
    # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
    idp_slo_target_url: 'https://suncountry.okta.com/app/suncountry_prosafet_1/exktiwa7r8Jnln8jT696/slo/saml',
    # idp_slo_target_url: 'https://suncountry.okta.com/app/suncountry_prosafet_1/exktiwa7r8Jnln8jT696/sso/saml',


    # Route to IdP; should be in metadata.xml under:
     # <EntityDescriptor ... entityID="|__this__|" />
    idp_entity_id: 'http://www.okta.com/exktiwa7r8Jnln8jT696',

    # Route to IdP's sign-in; should be in metadata.xml under:
     # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
    #idp_sso_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/POST/SSO',
    idp_sso_target_url: 'https://suncountry.okta.com/app/suncountry_prosafet_1/exktiwa7r8Jnln8jT696/sso/saml',

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
      signing_cert:     'MIIDpDCCAoygAwIBAgIGAXr5gexiMA0GCSqGSIb3DQEBCwUAMIGSMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxEzARBgNVBAMMCnN1bmNvdW50cnkxHDAaBgkqhkiG9w0BCQEW DWluZm9Ab2t0YS5jb20wHhcNMjEwNzMwMjIyMDE5WhcNMzEwNzMwMjIyMTE5WjCBkjELMAkGA1UE BhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDTALBgNV BAoMBE9rdGExFDASBgNVBAsMC1NTT1Byb3ZpZGVyMRMwEQYDVQQDDApzdW5jb3VudHJ5MRwwGgYJ KoZIhvcNAQkBFg1pbmZvQG9rdGEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA ro8GpeHzwN+M+Oiob1wURrHocJhsGONio8S9NcGB764qdpGegm8sw4+56ndrRQ8jhsv/Psl2Pz25 nq+ObT7dfaPVFiegfKTjr0qp0I0FTB6X4YgOuKyWKpSa2paO+0zW/St9fgasnUmm2T0M1dQUnosv 5JBR3U+XNEmhq9bS3bXKf95Kf8IDxJrT7vmHK5dZKxjXCj0vEJr7cOoAlCpjAyxqUpwgrIWV7dPM rthbAGyIB9i7SJXIHWA6hwer75Dd6cUMligoHgHID3FydkN8zOsPMBJpT+brm7ARH13qmnApafvN CjLuBqPRR2IcDobQ61j6YxhH199HJ8PqpiAhvwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQA2UFeD oyTsv3OfTop5aORlSa3WROa4r5p3QdK6Ht6Xr6VQy75FrIi9t/xa/81JLkP/V32w591kiIerBLFA YfKJ6noYmge3DQwv4kQsG5varsaAHIQa0h5iU7Xh/OduMLHhdDFY2hJ0e2l/cZGSCfbFq1ZBrA93 I50kQjfixDQHpyOgcGbYMK3h1JS091341ybVtwvaGqYVCH6YKEd2IVNig2uE40rfDnGduiD2lF4f mph5lZgPtBQyj+e3k2vuRp2tJfZy0ZF3d8MGyCK/X1oczHmQBMlD4iFUX9g0lVcqbC1A3w0jGVyO N+NjTyovZfmyfqkr+hVhAkQ0Tre+OAFw',

      # Certificate used for encrypting the response
      encryption_cert:  'MIIDpDCCAoygAwIBAgIGAXr5gexiMA0GCSqGSIb3DQEBCwUAMIGSMQswCQYDVQQGEwJVUzETMBEG A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU MBIGA1UECwwLU1NPUHJvdmlkZXIxEzARBgNVBAMMCnN1bmNvdW50cnkxHDAaBgkqhkiG9w0BCQEW DWluZm9Ab2t0YS5jb20wHhcNMjEwNzMwMjIyMDE5WhcNMzEwNzMwMjIyMTE5WjCBkjELMAkGA1UE BhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDTALBgNV BAoMBE9rdGExFDASBgNVBAsMC1NTT1Byb3ZpZGVyMRMwEQYDVQQDDApzdW5jb3VudHJ5MRwwGgYJ KoZIhvcNAQkBFg1pbmZvQG9rdGEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA ro8GpeHzwN+M+Oiob1wURrHocJhsGONio8S9NcGB764qdpGegm8sw4+56ndrRQ8jhsv/Psl2Pz25 nq+ObT7dfaPVFiegfKTjr0qp0I0FTB6X4YgOuKyWKpSa2paO+0zW/St9fgasnUmm2T0M1dQUnosv 5JBR3U+XNEmhq9bS3bXKf95Kf8IDxJrT7vmHK5dZKxjXCj0vEJr7cOoAlCpjAyxqUpwgrIWV7dPM rthbAGyIB9i7SJXIHWA6hwer75Dd6cUMligoHgHID3FydkN8zOsPMBJpT+brm7ARH13qmnApafvN CjLuBqPRR2IcDobQ61j6YxhH199HJ8PqpiAhvwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQA2UFeD oyTsv3OfTop5aORlSa3WROa4r5p3QdK6Ht6Xr6VQy75FrIi9t/xa/81JLkP/V32w591kiIerBLFA YfKJ6noYmge3DQwv4kQsG5varsaAHIQa0h5iU7Xh/OduMLHhdDFY2hJ0e2l/cZGSCfbFq1ZBrA93 I50kQjfixDQHpyOgcGbYMK3h1JS091341ybVtwvaGqYVCH6YKEd2IVNig2uE40rfDnGduiD2lF4f mph5lZgPtBQyj+e3k2vuRp2tJfZy0ZF3d8MGyCK/X1oczHmQBMlD4iFUX9g0lVcqbC1A3w0jGVyO N+NjTyovZfmyfqkr+hVhAkQ0Tre+OAFw',

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
