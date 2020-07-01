desc 'Send email '
task :submission_notify => [:environment] do |t|

  logger = Logger.new("log/notify.log")

  logger.info '##############################'
  logger.info '###       NOTIFY LOG       ###'
  logger.info '##############################'
  logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

  logger.info "#{ENV['OWNER_TYPE']}"
  logger.info "#{ENV['OWNER_ID']}"
  logger.info "#{ENV['USERS']}"
  logger.info '##############################'

  controller = ApplicationController.new
  users    = ENV['USERS'][1..-2].split(', ')
  owner_type = ENV['OWNER_TYPE']
  owner_id   = ENV['OWNER_ID']
  owner = Object.const_get(owner_type).find(owner_id)

  users.each do |user_id|
    if CONFIG.sr::GENERAL[:direct_content_message]

      html = controller.render_to_string(:template => "/submissions/_print.html.erb",  locals: {owner: owner, deidentified: true}, layout: false)
      pdf = PDFKit.new(html)
      pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
      pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
      attachment = pdf.to_pdf

      controller.notify(owner, notice: {
        users_id: user_id,
        content: "A new #{owner.template.name} submission is submitted. (##{owner.id} #{owner.description})",},
        mailer: true, subject: "New #{owner.template.name} Submission",
        attachment: attachment
      )
    else
      controller.notify(owner, notice: {
        users_id: user_id,
        content: "A new #{owner.template.name} submission is submitted. (##{owner.id} #{owner.description})",},
        mailer: true, subject: "New #{owner.template.name} Submission",
      )
    end
  end

end


desc 'Send email notification'
task :notify => [:environment] do |t|
  logger = Logger.new("log/notify.log")

  logger.info '##############################'
  logger.info '###       NOTIFY LOG       ###'
  logger.info '##############################'
  logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

  logger.info "#{ENV['OWNER_TYPE']}"
  logger.info "#{ENV['OWNER_ID']}"
  logger.info '##############################'

  if CONFIG.sr::GENERAL[:direct_content_message]
    controller = ApplicationController.new
    owner_type = ENV['OWNER_TYPE']
    owner_id   = ENV['OWNER_ID']

    # TODO: add other record types
    if false
      @record = Object.const_get(owner_type).find(owner_id)

      html = controller.render_to_string(:template => "/records/_print.html.erb",  locals: {owner: @record, deidentified: true}, layout: false)
      pdf = PDFKit.new(html)
      pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
      pdf.stylesheets << ("#{Rails.root}/public/css/print.css")

      attachment = pdf.to_pdf
    end

    send_to = eval ENV['SEND_TO']
    cc_to = eval ENV['CC_TO']

    if send_to.present? && send_to.values.find{|val| val == "-1"}.nil?
      send_to.values.each do |v|
        SendTo.create(messages_id: ENV['MESSAGES_ID'], users_id: v, anonymous: (ENV['TO_ANONYMOUS'] || false))
        controller.notify(@record,
          notice: {users_id: v, content: "You have a new message in ProSafeT."},
          mailer: true,
          subject:  ENV['SUBJECT'])
      end
    end

    if cc_to.present?
      cc_to.values.each do |v|
        CC.create(messages_id: ENV['MESSAGES_ID'], :users_id => v)
        controller.notify(@record,
          notice: {users_id: v, content: "You have a new message in ProSafeT."},
          mailer: true,
          subject: ENV['SUBJECT'])
      end
    end
  else
    if send_to.present? && send_to.values.find{|val| val == "-1"}.nil?
      send_to.values.each do |v|
        SendTo.create(messages_id: ENV['MESSAGES_ID'], users_id: v, anonymous: (ENV['TO_ANONYMOUS'] || false))
        controller.notify(@record,
          notice: {users_id: v, content: "You have a new message in ProSafeT."},
          mailer: true,
          subject: 'New Internal Message')
      end
    end

    if cc_to.present?
      cc_to.values.each do |v|
        CC.create(messages_id: ENV['MESSAGES_ID'], :users_id => v)
        controller.notify(@record,
          notice: {users_id: v, content: "You have a new message in ProSafeT."},
          mailer: true,
          subject: 'New Internal Message')
      end
    end
  end

  logger.info 'SENT'
  logger.info '##############################'

end
