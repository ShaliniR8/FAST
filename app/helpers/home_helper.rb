module HomeHelper

  def order_visualizations_by_pin_size(pinned_visualizations)
    arr_group_by_column_size = []
    arr_temp = []
    column_size = 0

    pinned_visualizations.sort_by(&:dashboard_pin_size).each do |vis|
      if vis.dashboard_pin_size + column_size > 12
        column_size = 0
        arr_group_by_column_size << arr_temp
        arr_temp = []
      end

      column_size += vis.dashboard_pin_size
      arr_temp << vis
    end

    arr_group_by_column_size << arr_temp
    arr_group_by_column_size.reject{|x| x.empty?}.flatten
  end


end
