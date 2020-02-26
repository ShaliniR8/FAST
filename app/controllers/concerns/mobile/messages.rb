#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Messages extend ActiveSupport::Concern

      def index_as_json
        current_user_id = current_user.id

        message_access_options = { methods: :getName, only: [:id, :status, :messages_id, :users_id] }

        messages_json = @messages.sort{ |a, b| b.time <=> a.time }.as_json(
          only: [:id, :content, :subject, :time, :owner_type, :owner_id],
          include: {
            send_from: message_access_options,
            send_to: message_access_options,
            cc: message_access_options,
            owner: { only: :id }
          }
        )

        unread = 0

        messages_json.each do |message|
          if message[:owner].blank?
            message.delete('owner_id')
            message.delete('owner_type')
            message.delete(:owner)
          end
          message.delete_if do |key, value|
            key.instance_of?(String) && key.include?('owner') && value.blank?
          end

          message[:send_from] = message[:send_from][:getName]

          [:send_to, :cc].each do |message_access_type|
            message[message_access_type].map! do |message_access|
              message[:status] = message_access['status'] if message_access['users_id'] === current_user_id
              message_access[:getName]
            end
          end

          unread += 1 unless message[:status] == 'Read'
        end

        render json: { unread: unread, messages: messages_json }
      end

      def read
        mark_as_read(current_user.id, params[:id])
        render json: { success: "Message ##{params[:id]} has been marked as read." }, status: 200
      end

    end
  end
end