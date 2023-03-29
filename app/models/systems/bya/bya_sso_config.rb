class BYASsoConfig
  SAML_DATA = {
    metadata_link: 'https://login.microsoftonline.com/be78e6f1-2071-4b0f-8ad1-acf82df376c0/federationmetadata/2007-06/federationmetadata.xml?appid=c0ec680e-430b-42d6-8234-ae74f5adf67e',

    response_consume_url: '/saml/consume',
    issuer_metadata_url:  '/saml/metadata',
    issuer_logout_url:    '/saml/logout',

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
