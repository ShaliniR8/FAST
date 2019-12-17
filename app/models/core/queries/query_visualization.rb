class QueryVisualization < ActiveRecord::Base

  belongs_to :query, foreign_key: :owner_id, class_name: 'Query'


  # def self.chart_types
  #   {
  #     'Grid'    => 1,
  #     'Pie'     => 2,
  #     'Column'  => 3,
  #     'Line'    => 4,
  #     'Stacked' => 5,
  #   }
  # end


  def self.chart_types
    [
      {val: 1, chart_name: 'Grid View',     options: {}},
      {val: 2, chart_name: 'Pie Chart',     options:  {
                                                        height: 400,
                                                        legend: {position: 'labeled'},
                                                        pieSliceText: 'annotationText',
                                                        tooltip: {textStyle: {color: 'black'}, showColorCode: true},
                                                      }},
      {val: 3, chart_name: 'Column Chart',  options: {
                                                        height: 400,
                                                        legend: { position: "top"},
                                                      }},
      {val: 4, chart_name: 'Line Chart',    options: {
                                                        chartArea: {height: "40%", width: "95%" },
                                                        legend: { position: "top" },
                                                        height: 400,
                                                      }},
      {val: 5, chart_name: 'Stacked Chart', options:  {
                                                        isStacked: true,
                                                        legend: { position: 'top', maxLines: 3 },
                                                        height: 400,
                                                      }},
    ]
  end


end
