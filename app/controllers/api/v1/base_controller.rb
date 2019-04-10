class Api::V1::BaseController < ApplicationController
	respond_to :json
	oauthenticate :interactive=>false
end
