#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Findings extend ActiveSupport::Concern

      def update_as_json
        render :json => { :success => 'Finding Updated.' }, :status => 200
      end

      def show_as_json
        render :json => findings_as_json(params[:id])
      end

      def findings_as_json(ids)
        findings = Finding.where(id: ids)

        # Get all fields that will be shown
        @fields = Finding.get_meta_fields('show')
          .select{ |field| field[:field].present? }

        # Array of fields to whitelist for the JSON
        json_fields = Finding.column_names.map(&:to_sym)

        # Include other fields that should always be whitelisted
        whitelisted_fields = [:id, *json_fields]
        json = findings.as_json(
                 only: whitelisted_fields,
                 include: {
                   attachments: {
                     only: [:id, :caption, :owner_id],
                     methods: :url
                   }
                 }
               ).map { |finding| format_finding_json(finding) }

        ids.is_a?(Array) ? array_to_id_map(json) : json[0]
      end

      def format_finding_json(finding)
        fields_attributes = @fields.map{|f| f[:field]}
        finding['get_status'] = finding['status']
        finding['get_source'] = ActionView::Base.full_sanitizer.sanitize(Finding.find(finding['id']).get_source).strip rescue ""

        finding_attachments = finding[:attachments]
        json = finding.delete_if{ |key, value| fields_attributes.exclude?(key) }
        json[:attachments_attributes] = {}

        finding_attachments.each do |attachment|
          attachment[:uri] = "#{request.protocol}#{request.host_with_port}#{attachment[:url]}"
          attachment.delete(:url)
          json[:attachments_attributes][attachment['id']] = attachment
        end

        # Creates a key map for all the meta field titles that will be shown
        json[:meta_field_titles] = {}
        @fields.each do |field|
          key = field[:field]
          json[:meta_field_titles][key] = field[:title]
        end

        json
      end

    end
  end
end
