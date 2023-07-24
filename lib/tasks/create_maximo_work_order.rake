require 'base64'
require 'rest-client'
require 'json'

username = 'integration'
password = 'Integration@1'
base_url = 'http://95.216.27.217/maximo'
encoded_credentials = Base64.encode64("#{username}:#{password}").chomp

desc 'Create Maximo Work Order'
task :create_maximo_work_order => [:environment] do |t|

  logger = Logger.new("log/maximo.log")

  logger.info '##############################'
  logger.info '###       MAXIMO LOG       ###'
  logger.info '##############################'
  logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

  description = ENV['DESCRIPTION']
  submission_id = ENV['SUBMISSION_ID']

  submission = Submission.find(submission_id.to_i)

  begin
    # CREATE Work Order
    create_wo_response = RestClient.post(
      "#{base_url}/oslc/os/prodigiq?lean=1",
      {
        siteid: 'KKIA',
        class: 'SR',
        classstructureid: 17011,
        internalpriority: 5, # 1..5
        status: 'NEW',
        description: description
      }.to_json,
      {
        accept: '*/*',
        content_type: :json,
        MAXAUTH: encoded_credentials
      }
    )

    # 201 => 'Created'
    if create_wo_response.code == 201
      # Work Order is created
      if create_wo_response.headers[:location]
        id = create_wo_response.headers[:location].split('/').last

        logger.info "Work Order is created: #{id}"
        logger.info "#{base_url}/oslc/os/prodigiq/#{id}?lean=1"

        # GET Work Order
        get_wo_response = RestClient.get "#{base_url}/oslc/os/prodigiq/#{id}?lean=1", {
          content_type: :json,
          MAXAUTH: encoded_credentials
        }

        # 200 => 'OK'
        if get_wo_response.code == 200
          response_hash = JSON.parse get_wo_response.body
          updated_status = response_hash['status_description']
          updated_note   = response_hash['description']

          wo_number_id = CONFIG::WORK_ORDER[:wo_number_id]
          wo_status_id = CONFIG::WORK_ORDER[:wo_status_id]
          wo_note_id   = CONFIG::WORK_ORDER[:wo_note_id]

          wo_number = submission.submission_fields.select { |field| [wo_number_id].include? field.fields_id }.first
          wo_status = submission.submission_fields.select { |field| [wo_status_id].include? field.fields_id }.first
          wo_note   = submission.submission_fields.select { |field| [wo_note_id].include? field.fields_id }.first

          wo_number.update_attribute(:value, id) if wo_number.present?
          wo_status.update_attribute(:value, updated_status)if wo_status.present?
          wo_note.update_attribute(:value, updated_note) if wo_note.present?


        else
          # FAILED TO retrieved WO information
        end
      end
    else
      # Work Order is NOT created
    end

  rescue Exception => e
  	logger.info e
  end

  logger.info 'SENT'
  logger.info '##############################'

end
