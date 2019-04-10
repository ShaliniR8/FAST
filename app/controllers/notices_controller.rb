class NoticesController < ApplicationController

	def destroy
		if Notice.find(params[:id]).destroy
			render json: {}, status: 200
		else
			render json: {}, status: 500
		end
	end

end
