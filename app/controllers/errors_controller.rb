class ErrorsController < ApplicationController
	def switch
		session[:mode]=params[:mode]
		redirect_to root_url
	end
end
