#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Audits extend ActiveSupport::Concern

      def update_as_json
        render :json => { :success => 'Audit Updated.' }, :status => 200
      end

      def index_as_json
        fetch_months = current_user.mobile_fetch_months
        @records = fetch_months > 0 ? Audit.where('created_at > ?', Time.now - fetch_months.months)
          : Audit.all
        filter_audits

        json = {}

        # Convert to id map for fast audit lookup
        json[:audits] = array_to_id_map @records.as_json(only: [:id, :status, :title, :completion])

        # Get ids of the 3 most recent assigned audits
        recent_audits = @records.keep_if{ |audit| audit[:status] == 'Assigned' }
          .last(3).as_json(only: :id).map{ |audit| audit['id'] }

        json[:recent_audits] = audits_as_json(recent_audits)

        render :json => json
      end

      def show_as_json
        render :json => audits_as_json(params[:id])
      end

      def audits_as_json(ids)
        audits = Audit.where(id: ids).includes({
          checklists: { # Preload checklists to prevent N+1 queries
            checklist_header: :checklist_header_items,
            checklist_rows: [:checklist_cells, :attachments],
          }
        })

        # Get all fields that will be shown
        @fields = Audit.get_meta_fields('show')
          .select{ |field| field[:field].present? }

        # Array of fields to whitelist for the JSON
        json_fields = @fields.map{ |field| field[:field].to_sym }

        # Include other fields that should always be whitelisted
        whitelisted_fields = [:id, *json_fields]

        json = audits.as_json(
          only: whitelisted_fields,
          include: { # Include checklist data required for mobile
            checklists: {
              only: [:id, :title],
              include: {
                checklist_header: {
                  only: :id,
                  include: {
                    checklist_header_items: {
                      only: [:id, :title, :data_type, :editable, :display_order, :size]
                    }
                  }
                },
                checklist_rows: {
                  only: [:id, :is_header],
                  include: {
                    checklist_cells: {
                      only: [:id, :value, :checklist_header_item_id, :options, :checklist_row_id]
                    },
                    attachments: {
                      only: [:id, :caption, :owner_id],
                      methods: :url
                    }
                  }
                }
              }
            }
          }
        ).map { |audit| format_audit_json(audit) }

        ids.is_a?(Array) ? array_to_id_map(json) : json[0]
      end

      def format_audit_json(audit)
        json = audit.delete_if{ |key, value| value.blank? }
        # Default checklists to an empty array
        json[:checklists] = [] if json[:checklists].blank?

        json[:attachments] = {}

        checklist_headers = {}
        json[:checklists] = json[:checklists].reduce({}) do |checklists, checklist|
          # Gathers all checklist headers that belong to this audit's checklists
          id = checklist[:checklist_header]['id']
          checklist_headers[id] ||= checklist[:checklist_header]
          checklist.delete(:checklist_header)

          # Creates id maps for checklist rows and checklist cells
          checklist[:checklist_rows] = checklist[:checklist_rows].reduce({}) do |checklist_rows, row|
            row[:attachments].each do |attachment|
              attachment[:uri] = "#{request.protocol}#{request.host_with_port}#{attachment[:url]}"
              attachment.delete(:url)
              json[:attachments][attachment['id']] = attachment
            end
            row.delete(:attachments)

            row[:checklist_cells] = row[:checklist_cells].reduce({}) do |checklist_cells, cell|
              if cell['options'].present?
                cell['options'] = cell['options']
                  .split(';')
                  .map!{ |option| option.strip }
                  .delete_if{ |option| option.blank? }
              end

              cell['value'].strip! if cell['value'].present?

              cell.delete_if do |key, value|
                value.blank? if key.match(/options|value/)
              end

              checklist_cells.merge({ cell['id'] => cell })
            end
            checklist_rows.merge({ row['id'] => row })
          end

           # Creates an id map for all checklists used in this audit
          checklists.merge({ checklist['id'] => checklist })
        end

        # Creates an id map for all checklist header items used in this audit
        json[:checklist_header_items] = checklist_headers.values
          .map{ |checklist_header| checklist_header[:checklist_header_items] }
          .flatten
        json[:checklist_header_items] = array_to_id_map json[:checklist_header_items]

        # Takes the id of each user field and replaces it with the
        # full name of the user corresponding to that id
        user_fields = @fields.select{ |field| field[:type] == 'user' }
        user_fields.map do |field|
          key = field[:field]
          user_id = json[key]
          json[key] = User.find(user_id).full_name rescue nil if user_id
        end

        # Creates a key map for all the meta field titles that will be shown
        json[:meta_field_titles] = {}
        @fields.each do |field|
          key = field[:field]
          json[:meta_field_titles][key] = field[:title] if json[key].present?
        end

        json
      end

    end
  end
end