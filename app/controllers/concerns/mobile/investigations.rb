#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Investigations extend ActiveSupport::Concern

      def index_as_json
        fetch_months = current_user.mobile_fetch_months
        @records = fetch_months > 0 ? Investigation.where("created_at > ? AND status != ?", Time.now - fetch_months.months, "New")
          : Investigation.all

        @records = @records.keep_if{|x| x[:template].nil? || !x[:template]}
        cars =  Object.const_get('Investigation').where('status in (?) and responsible_user_id = ?',
          ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
        cars +=  Object.const_get('Investigation').where('status in (?) and approver_id = ?',
          ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
        if current_user.has_access('investigations','viewer')
           Object.const_get('Investigation').where('viewer_access = true').each do |viewable|
            if viewable.privileges.blank?
              cars += [viewable]
            else
              viewable.privileges.each do |privilege|
                current_user.privileges.include? privilege
                cars += [viewable]
              end
            end
          end
        end
        cars +=  Object.const_get('Investigation').where('created_by_id = ?', current_user.id)
        @records = @records & cars

        json = {}

        # Convert to id map for fast investigation lookup
        json[:investigations] = array_to_id_map @records.as_json(only: [:id, :status, :title, :due_date])

        has_admin_access = current_user.has_access(Object.const_get('Checklist').rule_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default])
        if has_admin_access
          json[:checklists] = array_to_id_map Checklist.where(owner_type: 'ChecklistHeader')
        else
          addressable_templates = current_user.get_all_checklist_addressable_templates
          json[:checklists] = array_to_id_map Checklist.where(owner_type: 'ChecklistHeader').keep_if {|t| addressable_templates.include?(t.title)}.as_json
        end

        # Get ids of the 3 most recent assigned investigations
        recent_investigations = @records.keep_if{ |investigation| investigation[:status] == 'Assigned' }
          .last(3).as_json(only: :id).map{ |investigation| investigation['id'] }

        json[:recent_investigations] = investigations_as_json(recent_investigations)

        # Get id map of all users
        json[:users] = array_to_id_map User.active.as_json(only: [:id, :full_name, :email, :employee_number])

        render :json => json
      end

      def show_as_json
        render :json => investigations_as_json(params[:id])
      end

      def investigations_as_json(ids)
        investigations = Investigation.where(id: ids).includes({
          checklists: { # Preload checklists to prevent N+1 queries
            checklist_header: :checklist_header_items,
            checklist_rows: [:checklist_cells, :attachments],
          }
        })

        # Get all fields that will be shown
        @fields = Investigation.get_meta_fields('show')
          .select{ |field| field[:field].present? }

        # Array of fields to whitelist for the JSON

        # json_fields = @fields.map{ |field| field[:field].to_sym }
        json_fields = Investigation.column_names.map(&:to_sym)


        # Include other fields that should always be whitelisted
        whitelisted_fields = [:id, *json_fields]

        json = investigations.as_json(
          only: whitelisted_fields,
          include: { # Include checklist data required for mobile
            checklists: {
              only: [:id, :title, :completion_percentage],
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
                      only: [:id, :value, :checklist_header_item_id, :options, :checklist_row_id, :data_type, :custom_options]
                    },
                    attachments: {
                      only: [:id, :caption, :owner_id],
                      methods: :url
                    },
                    findings: {
                      only: [:id, :title, :status]
                    }
                  }
                }
              }
            }
          }
        ).map { |investigation| format_investigation_json(investigation) }

        ids.is_a?(Array) ? array_to_id_map(json) : json[0]
      end

      def format_investigation_json(investigation)
        json = investigation.delete_if{ |key, value| value.blank? }
        # Default checklists to an empty array
        json[:checklists] = [] if json[:checklists].blank?

        json[:attachments] = {}

        checklist_headers = {}
        json[:checklists] = json[:checklists].reduce({}) do |checklists, checklist|
          # Gathers all checklist headers that belong to this investigation's checklists
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

              if cell['custom_options'].present?
                cell['custom_options'] = cell['custom_options']
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

           # Creates an id map for all checklists used in this investigation
          checklists.merge({ checklist['id'] => checklist })
        end

        # Creates an id map for all checklist header items used in this investigation
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
