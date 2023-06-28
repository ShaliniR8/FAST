class Api::V1::UsersController < ApplicationController
  before_filter :authenticate_client

  def find_user
    user = User.where(email: params[:email]).first
    render json: user.as_json(only: %i[id full_name])
  end

  def sync
    user = User.where(email: params[:email]).first || User.new(email: params[:email].first, sso_id: params[:email].first)

    user.username = params[:username]
    user.first_name = params[:first_name]
    user.last_name = params[:last_name]
    user.full_name = "#{params[:first_name]} #{params[:last_name]}"
    user.email = params[:email][1]
    user.sso_id = params[:email][1]
    user.level = params[:level]
    user.level = 'Global Admin' if user.level == 'Account Manager'
    user.disable = params[:disable]

    user.save
    render json: nil
  end

  private

    def authenticate_client
      client_id = request.headers['Client-ID']
      client_secret = request.headers['Client-Secret']
      @app = ClientApplication.where(name: client_id).first

      return if @app.present? && @app.secret == client_secret

      render json: 'Authentication failed. Please verify your Client ID and Secret are correct.',
             status: :unauthorized
    end


end
