class TimeController < ApplicationController

  def now
    s = DateTime.now.in_time_zone.strftime('%Y-%m-%d %H:%M')
    render :text=>s,:layout=>false
  end

end
