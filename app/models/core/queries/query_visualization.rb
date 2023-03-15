class QueryVisualization < ActiveRecord::Base
  include QueriesHelper

  belongs_to :query, foreign_key: :owner_id, class_name: 'Query'


  DEFAULT_OPTIONS = {
    height: 400,
    legend: {position: 'top'},
    hAxis: {
      textStyle: {fontSize: 14}
    },
    titleTextStyle: {
      fontSize: 18,
      bold: true,
      fontName: "Quattrocento Sans"
    },
    tooltip: {
      textStyle: {
        fontSize: 14,
        fontName: "Quattrocento Sans"
      },
      showColorCode: true,
    }
  }


  def self.chart_types
    [
      {val: 1, chart_name: 'Grid',     options: {}},
      {val: 2, chart_name: 'Pie Chart',
        options:  DEFAULT_OPTIONS.deep_merge({
          legend: {position: 'labeled'},
          pieSliceText: 'annotationText',
          tooltip: {
            textStyle: {color: 'black'},
            showColorCode: true},
        }),
      },
      {val: 3, chart_name: 'Column Chart',
        options: DEFAULT_OPTIONS.deep_merge({
          seriesType: 'bars',
        }),
      },
      {val: 4, chart_name: 'Line Chart',
        options: DEFAULT_OPTIONS.deep_merge({
          seriesType: 'line',
        }),
      },
      {val: 5, chart_name: 'Stacked Chart',
        options: DEFAULT_OPTIONS.deep_merge({
          isStacked: true,
          legend: {maxLines: 3},
        }),
      },
    ]
  end


  def self.get_field(query, object_type, field_label)
    # label = field_label.split(',').map(&:strip)[0]
    label = field_label

    # if top level field
    field = object_type.get_meta_fields('show', 'index', 'invisible', 'query', 'close')
      .keep_if{|f| f[:title] == label}.first
    # else check template fields
    field = Template.preload(:categories, :fields)
      .where(id: query.templates)
      .map(&:fields)
      .flatten
      .select{|x| x.label.strip == label.strip}
      .first if field.nil?
    # [field, field_label.split(',').map(&:strip)[1]]
    [field, field_label]
  end


  def get_home_label
    if x_axis.present? && series.present?
      "#{x_axis} by #{series} FROM Query ##{query.id} - #{query.title}"
    elsif x_axis.present?
      "#{x_axis} FROM Query ##{query.id} - #{query.title}"
    else
      "#{series} FROM Query ##{query.id} - #{query.title}"
    end
  end


  def generate_vis(records_ids, owner)
    # owner = self.query
    object_type = Object.const_get(owner[:target])
    records_ids = records_ids.flatten

    x_axis_field = QueryVisualization.get_field(owner, object_type, x_axis)
    series_field = QueryVisualization.get_field(owner, object_type, series)

    if series.present? && x_axis.present? # if series present, build data from both values
      data = get_data_table_for_google_visualization_with_series(x_axis_field_name: x_axis,
                                                                  x_axis_field_arr: x_axis_field,
                                                                  series_field_arr: series_field,
                                                                  records_ids: records_ids,
                                                                  get_ids: false,
                                                                  query: owner)

    elsif x_axis.present?
      data = get_data_table_for_google_visualization_sql(x_axis_field_arr: x_axis_field, records_ids: records_ids, query: owner)

      if data.length == 1
        data << ['N/A', 0]
      end

    elsif series.present?
      data = get_data_table_for_google_visualization_sql(x_axis_field_arr: series_field, records_ids: records_ids, query: owner)

      if data.length == 1
        data << ['N/A', 0]
      end

    end

    data = data.map{ |x| [x[0].to_s, x[1..-1]].flatten}
    data
  end


  def compute_visualization(user_id, owner_id, vis_file_path, vis_processing_file_path, records_ids, query)
    File.open(vis_processing_file_path, "w") do |file|
      file.write("processing...")
    end

    data = generate_vis(records_ids, query)

    File.open(vis_file_path, "w") do |file|
      file.write(data.to_yaml)
    end

    File.delete(vis_processing_file_path)

    # Create message for the user that is recomputing visualizations
    message = Message.create(
      subject: "Visualization ##{id} for Query ##{owner_id} is READY",
      content: "The visualization ##{id} for Query ##{owner_id} has finished processing. Please check Dashboard page for the results. Thank you."
    )
    message.time = Time.now
    message.save
    SendFrom.create(
      messages_id: message.id,
      users_id: user_id,
      anonymous: false
    )
    SendTo.create(
      messages_id: message.id,
      users_id: user_id,
      anonymous: false
    )
  end


end
