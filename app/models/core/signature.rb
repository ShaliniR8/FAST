class Signature < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  mount_uploader :path, SignatureUploader

  # after_create :create_transaction #TODO: Uncommit when controller Update functions handle "Sign" commit

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['form', 'show'] : args)
    [
      {field: 'id',           title: 'ID',              num_cols: 6,    type: 'text',   visible: 'index',     required: false },
      {field: 'signee_name',  title: 'Signee Name',     num_cols: 6,    type: 'text',   visible: 'show,form', required: true, censor_deid: true },
      {field: 'created_at',   title: 'Date Signed',     num_cols: 6,    type: 'date',   visible: 'show',      required: false }
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def path=(data)
    if data.respond_to?('start_with?') && data.start_with?('data:image/png;base64')
      self.path = CarrierStringIO.new(Base64.decode64(data.split(',')[1]))
      Rails.logger.debug 'Recoded path definition from base64'
    else
      super
    end
  end

  def create_transaction
    Transaction.build_for(
      self.owner,
      "#{self.owner.class.name.titleize} Signed",
      (session[:simulated_id] || session[:user_id]),
      "Signed by #{self.signee_name}"
    )
  end
end

class CarrierStringIO < StringIO
  def original_filename
    "#{Time.now}_signature.PNG"
  end
  def content_type
    'image/png'
  end
end
