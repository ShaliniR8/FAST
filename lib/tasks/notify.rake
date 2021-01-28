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
  attach_pdf = ENV['ATTACH_PDF']

  owner = Object.const_get(owner_type).find(owner_id)
  content = owner.template.notifier_message.gsub("\n", '<br>') rescue nil
  content = ("A new #{owner.template.name} submission is submitted." + "(##{owner.send(CONFIG.sr::HIERARCHY[:objects]['Submission'][:fields][:id][:field])} " + "#{owner.description})") if !content.present?
  users.each do |user_id|
    if attach_pdf == 'true'

      html = controller.render_to_string(:template => "/pdfs/_print_submission.html.erb",  locals: {owner: owner, deidentified: false}, layout: false)
      pdf = PDFKit.new(html)
      pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
      pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
      attachment = pdf.to_pdf


      controller.notify(owner, notice: {
        users_id: user_id,
        content: content},
        mailer: true, subject: "New #{owner.template.name} Submission",
        attachment: attachment
      )
    else
      controller.notify(owner, notice: {
        users_id: user_id,
        content: content},
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

  logger.info "MESSAGES_ID: #{ENV['MESSAGES_ID']}"
  logger.info "OWNER_TYPE:  #{ENV['OWNER_TYPE']}"
  logger.info "OWNER_ID:    #{ENV['OWNER_ID']}"
  logger.info "SEND_TO:     #{ENV['SEND_TO']}"
  logger.info "CC_TO:       #{ENV['CC_TO']}"
  logger.info '##############################'

  send_to = eval ENV['SEND_TO']
  cc_to   = eval ENV['CC_TO']
  controller = ApplicationController.new
  @message = Message.find(ENV['MESSAGES_ID'])
  attachment = nil

  # if false # TODO: add other record types
  if ENV['ATTACH_PDF'] == "1" && ENV['OWNER_TYPE'].present? && ENV['OWNER_ID'].present? # TODO: add other record types
    owner_type = ENV['OWNER_TYPE']
    owner_id   = ENV['OWNER_ID']
    @record = Object.const_get(owner_type).find(owner_id)

    case owner_type
    when "Submission"
      html = controller.render_to_string(:template => "/pdfs/_print_submission.html.erb",  locals: {owner: @record, deidentified: true}, layout: false)
    when "Record"
      html = controller.render_to_string(:template => "/pdfs/_print_record.html.erb",  locals: {owner: @record, deidentified: true}, layout: false)
    when "Report"
      html = controller.render_to_string(:template => "/pdfs/_print_report.html.erb",  locals: {owner: @record, deidentified: true, first_print: true}, layout: false)
    else
      html = controller.render_to_string(:template => "/pdfs/_print.html.erb",  locals: {owner: @record, deidentified: true}, layout: false)
    end

    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")

    attachment = pdf.to_pdf
  end

  if send_to.present? && send_to.values.find{|val| val == "-1"}.nil?
    send_to.values.each do |v|
      SendTo.create(messages_id: ENV['MESSAGES_ID'], users_id: v, anonymous: (ENV['TO_ANONYMOUS'] || false))

      logger.info "Notification sent to #{User.find(v).full_name}"
      if ENV['EXTRA_ATTACHMENTS'].to_i > 0
        controller.notify(@message,
        notice: {users_id: v, content: "You have a new message in ProSafeT."},
        mailer: true,
        extra_attachments: ENV['EXTRA_ATTACHMENTS'].to_i,
        subject:  ENV['SUBJECT'],
        attachment: attachment)
      else
        controller.notify(@message,
        notice: {users_id: v, content: "You have a new message in ProSafeT."},
        mailer: true,
        subject:  ENV['SUBJECT'],
        attachment: attachment)
      end
    end
  end

  if cc_to.present?
    cc_to.values.each do |v|
      CC.create(messages_id: ENV['MESSAGES_ID'], :users_id => v)
      if ENV['EXTRA_ATTACHMENTS'].to_i > 0
        controller.notify(@message,
        notice: {users_id: v, content: "You have a new message in ProSafeT."},
        mailer: true,
        extra_attachments: ENV['EXTRA_ATTACHMENTS'].to_i,
        subject: ENV['SUBJECT'],
        attachment: attachment)
      else
        controller.notify(@message,
        notice: {users_id: v, content: "You have a new message in ProSafeT."},
        mailer: true,
        subject: ENV['SUBJECT'],
        attachment: attachment)
      end
    end
  end

  logger.info 'SENT'
  logger.info '##############################'

end
