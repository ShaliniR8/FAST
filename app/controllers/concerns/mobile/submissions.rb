#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Submissions extend ActiveSupport::Concern

      def update_as_json(flash)
        render :json => flash, :status => 200
      end

      def index_as_json
        fetch_months = current_user.mobile_fetch_months

        @complete_records, @incomplete_records = [true, false].map do |completed|
          records = Submission.where({
            user_id: current_user.id,
            completed: completed,
          }).includes(:template)

          records = records.can_be_accessed(current_user) if completed

          records = records.where('created_at > ?', Time.now - fetch_months.months) if fetch_months > 0
          records
        end

        json = {}

        # Convert to id map for fast lookup
        json[:submissions] = [@complete_records, @incomplete_records].map{ |records|
          records.as_json(
            only: [:id, :completed, :description, :event_date],
            include: { template: { only: :name }}
          )
          .map do |submission|
            submission[:template_name] = submission[:template]['name']
            submission.delete(:template)
            submission
          end
        }.flatten
        json[:submissions] = array_to_id_map json[:submissions]

        json[:templates] = submission_templates_as_json

        json[:meta_field_titles] = Submission.get_meta_fields('show').reduce({}) do |meta_field_titles, meta_field|
          field = meta_field[:field]
          field = meta_field[:field].split('_').drop(1).join('_') if field.include? 'get'
          field = 'submitted_by' if field == 'user_id'
          meta_field_titles.merge({ field => meta_field[:title] })
        end

        # Get ids of the 3 most recent completed submissions and 3 most recent in progress submissions
        recent_submissions = [true, false].map do |completed|
          records = completed ? @complete_records : @incomplete_records
          records.last(3).as_json(only: :id).map{ |submission| submission['id'] }
        end

        json[:recent_submissions] = submissions_as_json(recent_submissions.flatten)

        # Get timezone data for timezone fields
        timezoneField = Field.where(data_type: 'timezone').first
        json[:timezones] = { all: timezoneField.getOptions.sort, us: timezoneField.getOptions2.sort }

        # Get id map of all users
        json[:users] = array_to_id_map User.all.as_json(only: [:id, :full_name, :email])

        render :json => json
      end

      def show_as_json
        render :json => submissions_as_json(params[:id])
      end

      def submissions_as_json(ids)
        submissions = Submission.where(id: ids).includes(:submission_fields, :attachments)

        json = submissions.as_json(
          only: [
            :id,
            :anonymous,
            :completed,
            :description,
            :event_date,
            :event_time_zone,
            :templates_id,
            :user_id,
          ],
          include: {
            submission_fields: {
              only: [:id, :fields_id, :value]
            },
            attachments: {
              only: [:id, :caption],
              methods: :document_filename
            }
          }
        ).map { |submission| format_submission_json(submission) }

        ids.is_a?(Array) ? array_to_id_map(json) : json[0]
      end

      def format_submission_json(submission)
        json = submission

        json[:submitted_by] = json['anonymous'] ? 'Anonymous' : User.find(json['user_id']).full_name rescue nil

        # Creates an id map based on template field id
        json[:submission_fields] = array_to_id_map json[:submission_fields], 'fields_id'

        # Attachments id map
        json[:attachments] = array_to_id_map json[:attachments]

        json
      end

      def submission_templates_as_json
        # Get templates the user has access to
        templates = Template.includes({ categories: :fields }).all

        unless current_user.has_access('submissions', 'admin', admin: true, strict: true)
          templates.keep_if do |template|
            current_user.has_template_access(template.name).match /full|submitter/
          end
        end

        # Get json data for templates
        templates_json = templates.as_json(
          only: [:id, :name, :map_template_id, :allow_anonymous],
          include: {
            categories: {
              only: [:id, :title, :category_order, :description, :deleted],
              include: {
                fields: {
                  only: [
                    :id,
                    :label,
                    :data_type,
                    :options,
                    :field_order,
                    :show_label,
                    :required,
                    :display_type,
                    :nested_field_id,
                    :nested_field_value,
                    :element_class,
                    :element_id,
                    :deleted,
                  ]
                }
              }
            }
          }
        )

        # sort categories and fields
        templates_json.each do |template|
          template[:categories].sort_by!{ |category| category['category_order'] }
          template[:categories].each do |category|
            # LOSAV fields
            new_fields = []
            follow_fields = nil
            master_fields = nil
            losav_options = nil
            # check for legacy LOSAV fields, convert to nested fields
            category[:fields].each do |child_field|
              # Rename LOSAV fields to include the name of their master field
              # Rename master field to include 'Condition'
              if (child_field['element_class'].match(/master|follow/i))
                master_fields ||= category[:fields]
                  .select{ |field| field['element_class'].include? 'master' }
                  .map{ |field| { element_id: field['element_id'], label: field['label'] } }

                if (child_field['element_class'] == 'master')
                  child_field['label'] = "#{child_field['label']}: Condition"
                else
                  master_field = master_fields.find{ |master_field| child_field['element_id'] == master_field[:element_id] }
                  child_field['label'] = "#{master_field[:label]}: #{child_field['label']}"
                end
              end
              if (child_field['element_class'].include? 'sub')
                # load LOSAV JSON and filter out the follow fields
                losav_options ||= JSON.parse(File.read(Rails.root.join('public', 'javascripts', 'templates', 'losav_options.json')))
                follow_fields ||= category[:fields].select{ |field| field['element_class'].include? 'follow' }

                parent_class = child_field['element_class'].gsub(/follow|sub/, '').strip

                parent_field = follow_fields.find do |parent_field|
                  parent_field['element_id'] == child_field['element_id'] &&
                    parent_field['element_class'].include?(parent_class)
                end

                if parent_field
                  # create new nested fields based on parent id and LOSAV JSON
                  parent_field['options']
                    .split(';')
                    .delete_if{ |option| option.blank? }
                    .each do |option|
                      new_field = child_field.clone
                      new_field['nested_field_id'] = parent_field['id']
                      new_field['nested_field_value'] = option
                      new_field['options'] = losav_options[option].join(';')
                      new_fields.push(new_field)
                    end

                  # set child_field to be deleted, replaced by new fields
                  child_field['deleted'] = true
                end

              end
            end
            # add created fields if any were made
            category[:fields].concat(new_fields)

            # convert field_orders to arrays, where nested_fields have parent order and sibling order
            nested_fields = []
            field_orders = category[:fields].map{ |field| { id: field['id'], field_order: field['field_order'] } }

            category[:fields].each do |field|
              field['field_order'] = [field['field_order']]

              if (field['nested_field_id'] != nil)
                parent_field = field_orders.find{ |parent_field| parent_field[:id] == field['nested_field_id'] }
                field['field_order'].unshift(parent_field[:field_order])
              end
            end

            category[:fields].sort!{ |a, b| a['field_order'] <=> b['field_order'] }
          end
        end

        # format and filter template data
        templates_json.each do |template|
          # remove deleted categories
          template[:categories].delete_if{ |category| category['deleted'] }
          template[:categories].each.with_index do |category, categoryIndex|
            category[:index] = categoryIndex

            # these keys are no longer necessary
            category.delete_if{ |key| key.match /category_order|deleted/ }

            # remove deleted fields
            category[:fields].delete_if{ |field| field['deleted'] }
            category[:fields].each.with_index do |field, fieldIndex|
              field[:index] = fieldIndex

              # reduce redundancy by setting fields with element_class of "required_field" as required
              field['required'] = true if field['element_class'] == 'required_field'

              # mark categories as required if they have any required fields
              category['required'] = true if field['required']

              # replace options string with an array, and remove empty values
              field['options'] = field['options']
                .split(';')
                .delete_if{ |option| option.empty? }

              field.delete_if do |key, value|
                case key
                # these keys are no longer necessary
                when /field_order|deleted|element_class|element_id/
                  true
                # these keys are only relevant if they have a value
                when /element_id|element_class|options|label|nested_field_value|nested_field_id|required|show_label/
                  value.blank?
                else
                  false
                end
              end
            end
          end
        end

        array_to_id_map templates_json
      end

      ########################################################
      #--- Temporary methods for legacy app compatibility ---#
      ########################################################
      # ------------- BELOW ARE EVERYTHING ADDED FOR PROSAFET APP
        #Added by BP Aug 8. render json for templates accessible to the current user
        def template_json
          @templates = Template.find(:all)
          @templates.keep_if{|x| (current_user.has_template_access(x.name).include? "full")||(current_user.has_template_access(x.name).include? "submitter")}
          stream = render_to_string(:template=>"submissions/template_json.js.erb" )
          send_data(stream, :type => "json", :disposition => "inline")
        end


        def user_submission_json
          @date = params[:date]
          @submissions = Submission.find(:all, :conditions => [ "created_at > ? and user_id = ?",@date,current_user.id])
          # @templates=Template.find(:all)
          stream = render_to_string(:template => "submissions/user_submission_json.js.erb" )
          response.headers['Content-Length'] = stream.bytesize.to_s
          send_data(stream, :type => "json", :disposition => "inline")
        end
      ###############################
      #--- End Temporary Methods ---#
      ###############################

    end
  end
end
