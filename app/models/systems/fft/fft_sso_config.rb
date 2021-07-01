class FFTSsoConfig

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
    access_point: 'https://login.microsoftonline.com/77ead82d-8a2e-4bc2-b8b3-2f8e0d161f2d/saml2',

    # Route to IdP's sign-out; should be in the following format:
    # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
    idp_slo_target_url: 'https://login.microsoftonline.com/77ead82d-8a2e-4bc2-b8b3-2f8e0d161f2d/saml2',


    # Route to IdP; should be in metadata.xml under:
     # <EntityDescriptor ... entityID="|__this__|" />
    idp_entity_id: 'https://sts.windows.net/77ead82d-8a2e-4bc2-b8b3-2f8e0d161f2d/',

    # Route to IdP's sign-in; should be in metadata.xml under:
     # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
    #idp_sso_target_url: 'https://flyfrontier.id.overwatchid.com/idp/profile/SAML2/POST/SSO',
    idp_sso_target_url: 'https://login.microsoftonline.com/77ead82d-8a2e-4bc2-b8b3-2f8e0d161f2d/saml2',

    # Specifies the route to the hash algorithm; standard format is sha1, s"http://www.w3.org/2000/09/xmldsig#sha1"

    ### Fingerprint Config ###

      # Fingerprint is less safe than the full certificate- only set to true and provide settings if needed
      use_fingerprint: false,

      # Value of fingerprint; should be in metadata.xml
      idp_cert_fingerprint: '',

      # Route to hash algorithm- standard is SHA1, you shouldn't have to alter this:
      # idp_cert_fingerprint_algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1',
      # idp_cert_fingerprint_algorithm: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
      idp_cert_fingerprint_algorithm: 'http://www.w3.org/2001/04/xmlenc#sha256',

    ### Certificate Config ###
      # This will be used in place of the fingerprint and is more secure
      # If only on certificate, place it under signing_cert
      # Do NOT include BEGIN-END tags on the certificates

      # Certificate used for signing the response
      signing_cert:     'MIIC8DCCAdigAwIBAgIQO0eSX7C9s4hJ9w/0asQl6jANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMTA2MDgyMDQ2MzNaFw0yNDA2MDgyMDQ2MzNaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAycLi/RxK82Q27AbXqDZKVkMqn5hHGi8ksVQbFem4mohiK4YlzLhH8IwM1EkfsmRnu3m4UG/oMiF+SdqlKfl2X/jj8MgLaeFmlht4ozsdvC1GUbP1p5EFrYstM8sAghb6myd/NfDjI3+8b5QUU7pVEz2gz8yW4InA5vu8Co86NxWVIIpLCnyTHeWBXczvxXmkf9xaUHtZALGQetG8mH+4Hbs9fiL7CjMYpTqtpjZAMiaOWUDOnQTi56W3lK2t4DBj/WpiMh3pNqWXbf5VKGxAajqI9UzBekbucmyqzbICSkWDhgzTxI/00j1dlsY1URxRpHWbvTkQRWgTlG5nsTuXnQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQCG1wOFym0vFTIPZX/atsTwyj3IPdNQNlwjr1EJIKXMdxt1T8wHxKvDOEVQu+wsMyRoOdiStu/A4kQgOQ32hshKcM42Kv3xebi+7T+68tGH2LMvGvGjjq/KcrxTXXChFT2kD4/DZKcHRqyQauo7Mzs6sixgon9Y3wmxkA6j6XLbgWwjO6GAoL031ikFWn/eLjVy9aWcmvTIZECgyarhF98YLu3wQ5F1Wf+OE31mJgB+rDMCzInedSZ1D9AUBocebe8qAOVss2RSkfEjeJX03Yms9rDlkDnkEf7sEqQnQbW3PMmJtd865f2mTCZvfsmzWZzLMCuVqQvc46u1TJfe+Cxx',

      # Certificate used for encrypting the response
      encryption_cert:  'MIIC8DCCAdigAwIBAgIQO0eSX7C9s4hJ9w/0asQl6jANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMTA2MDgyMDQ2MzNaFw0yNDA2MDgyMDQ2MzNaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAycLi/RxK82Q27AbXqDZKVkMqn5hHGi8ksVQbFem4mohiK4YlzLhH8IwM1EkfsmRnu3m4UG/oMiF+SdqlKfl2X/jj8MgLaeFmlht4ozsdvC1GUbP1p5EFrYstM8sAghb6myd/NfDjI3+8b5QUU7pVEz2gz8yW4InA5vu8Co86NxWVIIpLCnyTHeWBXczvxXmkf9xaUHtZALGQetG8mH+4Hbs9fiL7CjMYpTqtpjZAMiaOWUDOnQTi56W3lK2t4DBj/WpiMh3pNqWXbf5VKGxAajqI9UzBekbucmyqzbICSkWDhgzTxI/00j1dlsY1URxRpHWbvTkQRWgTlG5nsTuXnQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQCG1wOFym0vFTIPZX/atsTwyj3IPdNQNlwjr1EJIKXMdxt1T8wHxKvDOEVQu+wsMyRoOdiStu/A4kQgOQ32hshKcM42Kv3xebi+7T+68tGH2LMvGvGjjq/KcrxTXXChFT2kD4/DZKcHRqyQauo7Mzs6sixgon9Y3wmxkA6j6XLbgWwjO6GAoL031ikFWn/eLjVy9aWcmvTIZECgyarhF98YLu3wQ5F1Wf+OE31mJgB+rDMCzInedSZ1D9AUBocebe8qAOVss2RSkfEjeJX03Yms9rDlkDnkEf7sEqQnQbW3PMmJtd865f2mTCZvfsmzWZzLMCuVqQvc46u1TJfe+Cxx',

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
