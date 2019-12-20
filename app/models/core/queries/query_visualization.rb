class QueryVisualization < ActiveRecord::Base

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


end
