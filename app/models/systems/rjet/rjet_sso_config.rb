class RJETSsoConfig
  SAML_DATA = {
    metadata_link: '',

    response_consume_url: '/saml/consume',
    issuer_metadata_url:  '/saml/metadata',
    issuer_logout_url:    '/saml/logout',

    #This determines the format of the identifying information- for any data format, you can use 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'
    name_id_format:    'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',

    # Location to send SAML request from ProSafeT, should be in the following format:
    # "|__IdP_domain__|/adfs/ls/idpinitiatedsignon"
    access_point: 'https://login.microsoftonline.com/2ebb9fda-6f05-43ed-8507-e83c949691ac/saml2',

    # Route to IdP's sign-out; should be in the following format:
    # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
    idp_slo_target_url: 'https://login.microsoftonline.com/2ebb9fda-6f05-43ed-8507-e83c949691ac/saml2',


    # Route to IdP; should be in metadata.xml under:
     # <EntityDescriptor ... entityID="|__this__|" />
    idp_entity_id: 'https://sts.windows.net/2ebb9fda-6f05-43ed-8507-e83c949691ac/',

    # Route to IdP's sign-in; should be in metadata.xml under:
     # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
    #idp_sso_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/POST/SSO',
    idp_sso_target_url: 'https://login.microsoftonline.com/2ebb9fda-6f05-43ed-8507-e83c949691ac/saml2',

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
      signing_cert:     'MIIC8DCCAdigAwIBAgIQF5+Qmixn5a9O1K7ccV/UijANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMTAyMTUxOTM4MDhaFw0yNDAyMTUxOTM4MDhaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtpA8YRoA3DPUdxsq6PCvi1Qc8AogzteOUBIgdnandnGiHX2+6S56qaZzh/P/3D2QziCesiGF+8rYraitgCQxCyFZJyZgsnLPeSfAUa+8vKPB/JU9k8xKPL2sk3X0ScESGXiJ57WzbCA7R617fVJ+/g9jbJJY9eTzrhNBLLxTeX3UATSf4SgQbHZ29yx+TyrBspzD01bJHT0gf3OwzY6atYlsVzrsduBwMDmYVfZv+EX52UxGfqv9YbQpBTsQPwPQIlmVOEzYxkDs3sae4tc+dPiI50qvdXepSqrzKh333TmaHZOHZUJu26zZLn8TwuADTg6Hyn+byR3DQsEweuRlPQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAj5fsX/kmZMuyFCU1C11dtNK3Q8smy0gpNXUBGthhNL7rELtePdz6qEEkfRzAchzNdTJ+9D8rbw0SjjH3mo5BUI5IrdJ4332qW7/KMxlpbW9cejiJUumIRAYWRhnm45LUStdXzGnHM5s63PKjGuaI2H4h7oUduM2/iot0MAeG06/1GnRU9Sj0xg2EJiXZmEDxocOd392nCWNaQrF47cEWrL69yt9ZxC+GssK4tX/TNnm/pRNnznM68GlrBo2z9ECMLXLONM4ZUqIENUeSWR/Mj6+r44H5PNf1jEyMDsuzPHEvMP0S0GwDWtj0gnEJ8rPNmm+9se8tUSpuIEDOkGYnd',

      # Certificate used for encrypting the response
      encryption_cert:  'MIIC8DCCAdigAwIBAgIQF5+Qmixn5a9O1K7ccV/UijANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMTAyMTUxOTM4MDhaFw0yNDAyMTUxOTM4MDhaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtpA8YRoA3DPUdxsq6PCvi1Qc8AogzteOUBIgdnandnGiHX2+6S56qaZzh/P/3D2QziCesiGF+8rYraitgCQxCyFZJyZgsnLPeSfAUa+8vKPB/JU9k8xKPL2sk3X0ScESGXiJ57WzbCA7R617fVJ+/g9jbJJY9eTzrhNBLLxTeX3UATSf4SgQbHZ29yx+TyrBspzD01bJHT0gf3OwzY6atYlsVzrsduBwMDmYVfZv+EX52UxGfqv9YbQpBTsQPwPQIlmVOEzYxkDs3sae4tc+dPiI50qvdXepSqrzKh333TmaHZOHZUJu26zZLn8TwuADTg6Hyn+byR3DQsEweuRlPQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAj5fsX/kmZMuyFCU1C11dtNK3Q8smy0gpNXUBGthhNL7rELtePdz6qEEkfRzAchzNdTJ+9D8rbw0SjjH3mo5BUI5IrdJ4332qW7/KMxlpbW9cejiJUumIRAYWRhnm45LUStdXzGnHM5s63PKjGuaI2H4h7oUduM2/iot0MAeG06/1GnRU9Sj0xg2EJiXZmEDxocOd392nCWNaQrF47cEWrL69yt9ZxC+GssK4tX/TNnm/pRNnznM68GlrBo2z9ECMLXLONM4ZUqIENUeSWR/Mj6+r44H5PNf1jEyMDsuzPHEvMP0S0GwDWtj0gnEJ8rPNmm+9se8tUSpuIEDOkGYnd',
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
