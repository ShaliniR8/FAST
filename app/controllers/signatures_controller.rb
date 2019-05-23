class SignaturesController < ApplicationController

  before_filter :define_owner, only: [:show]

  def define_owner
    @class = Object.const_get('Signature')
    @owner = Signature.find(params[:id])
  end

  def show
    signature = Signature.find(params[:id])
    full_path = @owner.path.current_path
    image_data = File.read(signature.path.current_path)
    send_data Base64.encode64(image_data), type: 'image/png', disposition: 'inline'
  end
end
