#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Checklists extend ActiveSupport::Concern

      def update_as_json(flash)
        render :json => flash, :status => 200
      end

      def show_as_json
        render :json => checklist_as_json(params[:id])
      end

      def checklist_as_json(id)
        ids = []
        ids << id
        checklists = Checklist.where(id: ids)

        json = checklists.as_json(
          only: [:id, :title, :owner_type],
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
        ).map { |checklist| format_checklist_json(checklist) }

        json[0]
      end

      def format_checklist_json(checklist)
        # json = checklist.delete_if{ |key, value| value.blank? }
        json = {}
        json[:attachments] = {}
        checklist_headers = {}

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
        json = checklist

        # Creates an id map for all checklist header items used in this audit
        json[:checklist_header_items] = checklist_headers.values
          .map{ |checklist_header| checklist_header[:checklist_header_items] }
          .flatten
        json[:checklist_header_items] = array_to_id_map json[:checklist_header_items]

        json
      end

    end
  end
end
