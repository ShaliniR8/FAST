class TrackingsController < ApplicationController
	before_filter :set_table_name
	def set_table_name
		@table_name="trackings"
	end
	def new
		@tracking=Tracking.new
		@category_options=Tracking.get_categories
		@priority_options=Tracking.get_priorities
	end

	def create
		@tracking=Tracking.new(params[:tracking])
		@tracking.save
		redirect_to tracking_path(@tracking)
	end

	def edit
		@tracking=Tracking.find(params[:id])
		@category_options=Tracking.get_categories
		@priority_options=Tracking.get_priorities
	end

	def update
		@tracking=Tracking.find(params[:id])
		@tracking.update_attributes(params[:tracking])
		redirect_to tracking_path(@tracking)
	end

	def destroy
		tracking=Tracking.find(params[:id])
		tracking.destroy
		redirect_to root_url
	end 

	def show 
		@tracking=Tracking.find(params[:id])
	end

	def index
		@title="Trackings"
		@records=Tracking.find(:all)
		@headers=Tracking.get_headers
	end

end
