class Recurrence < ActiveRecord::Base
  extend AnalyticsFilters

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',           title: 'ID',                num_cols: 6, type: 'text',          visible: 'index,show',       required: false},
      {field: 'title',        title: 'Recurrence Title',  num_cols: 6, type: 'text',          visible: 'index,form,show',  required: true},
      {field: 'form_type',    title: 'Type',              num_cols: 6, type: 'text',          visible: 'show',             required: false},
      {field: 'frequency',    title: 'Frequency',         num_cols: 6, type: 'select',        visible: 'index,form,show',  required: true, options: CONFIG.sa::GENERAL[:daily_weekly_recurrence_frequecies] ? "Recurrence.get_frequency_daily_weekly" : "Recurrence.get_frequency"},
      {field: 'next_date',    title: 'Next Creation Date',num_cols: 6, type: 'date',          visible: 'index,form,show',  required: true},
      {field: 'end_date',     title: 'End Date',          num_cols: 6, type: 'date',          visible: 'index,form,show',  required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def self.get_meta_fields_spawns(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',                                     title: 'ID',                                          num_cols: 6, type: 'text',          visible: 'index,show',       required: false},
      {field: 'title',                                  title: 'Recurrence Title',                            num_cols: 6, type: 'text',          visible: 'index,form,show',  required: true},
      {field: 'form_type',                              title: 'Type',                                        num_cols: 6, type: 'text',          visible: 'show',             required: false},
      {field: 'frequency',                              title: 'Frequency',                                   num_cols: 6, type: 'select',        visible: 'index,form,show',  required: true, options: CONFIG.sa::GENERAL[:daily_weekly_recurrence_frequecies] ? "Recurrence.get_frequency_daily_weekly" : "Recurrence.get_frequency"},
      {field: 'number_of_recurrencies_per_interval',    title: 'Number of Recurrencies per Interval',         num_cols: 6, type: 'select',        visible: 'index,form,show',  required: true, options: (1..10).to_a},
      {field: 'next_date',                              title: 'Next Creation Date',                          num_cols: 6, type: 'date',          visible: 'index,form,show',  required: true},
      {field: 'end_date',                               title: 'End Date',                                    num_cols: 6, type: 'date',          visible: 'index,form,show',  required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_frequency_daily_weekly
    [
      'Daily',
      'Weekly',
      'Monthly',
      'Quarterly',
      '6 Months',
      'Yearly',
      'Biennial'
    ]
  end
  def self.get_frequency
    [
      'Monthly',
      'Quarterly',
      '6 Months',
      'Yearly',
      'Biennial'
    ]
  end

  def self.month_count
    {
      'Daily'           => { :number => 1 },
      'Weekly'          => { :number => 7  },
      'Monthly'         => { :number => 1    },
      'Quarterly'       => { :number => 3    },
      '6 Months'        => { :number => 6    },
      'Yearly'          => { :number => 12   },
      'Biennial'        => { :number => 24   },
    }
  end

  def children
    type = Object.const_get(self.form_type)
    type.where(recurrence_id: self.id)
  end

end
