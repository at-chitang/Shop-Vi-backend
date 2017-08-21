class Api::V1::SessionsController < ApplicationController
  before_action :logged_in?, only: :destroy

  def create
    user = User.find_by_email(params[:email])
    # binding.pry
    if user && user.authenticate(params[:password])
      if user.active
        user.update_columns(auth_token: SecureRandom.hex)
        render json: user, serializer: Users::UserSerializer
      else
        error = { error: { message: 'Didn\'t confirm email', status: 404 } }
        render json: error
      end
    else
      error = { error: { message: 'Invalid email/password', status: 404 } }
      render json: error
    end
  end

  def destroy
    user = User.find_by(params[:id])
    # binding.pry
    if user
      user.update_columns(auth_token: nil) if user.auth_token == response.request.env['HTTP_AUTH_TOKEN']
      message = { message: { msg: 'You logged out!', status: 200 } }
      render json: message
    else
      error = { error: { message: 'Invalid user!', status: 404 } }
      render json: error
    end
  end
end
