class SignaturesController < ApplicationController
  before_filter:
  def display_signature
    full_path = signature.path.current_path
    Rails.logger.debug "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ HIT"
    current_signature = Signature.find(params[:id])
    send_file current_signature.path.current_path, type: 'image/png', disposition: 'inline'
  end
end



  # def display_image
  #   Rails.logger.debug "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  #   # Rails.logger.debug "#{full_path} #{full_path.class.name}"
  #   # "#{Rails.root.to_s}/app/assets/signature/path/#{owner.id}/#{owner.path}", type: 'image/png', disposition: 'inline'
  # end
