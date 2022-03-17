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
        json = findings.as_json(only: whitelisted_fields).map { |finding| format_finding_json(finding) }

        ids.is_a?(Array) ? array_to_id_map(json) : json[0]
      end

      def format_finding_json(finding)
        fields_attributes = @fields.map{|f| f[:field]}
        json = finding.delete_if{ |key, value| fields_attributes.exclude?(key) }

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
          json[:meta_field_titles][key] = field[:title]
        end

        json
      end

    end
  end
end
