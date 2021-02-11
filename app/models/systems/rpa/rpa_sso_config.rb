class RPASsoConfig
  SAML_DATA = {

      # metadata_link: 'https://syextec0002.suncountry.com/FederationMetadata/2007-06/FederationMetadata.xml',

      response_consume_url: '/saml/consume',
      issuer_metadata_url:  '/saml/metadata',
      issuer_logout_url:    '/saml/logout',

      name_id_format:    'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',

      # access_point: 'https://syextec0002.suncountry.com/adfs/ls/idpinitiatedsignon',

      # idp_slo_target_url: 'https://syextec0002.suncountry.com/adfs/ls/?wa=wsignout1.0',
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
