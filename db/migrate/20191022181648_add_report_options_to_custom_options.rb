class AddReportOptionsToCustomOptions < ActiveRecord::Migration
  def self.up
    CustomOption.create(
      title:        'Event Types',
      field_type:   'Checkbox',
      options:      'Aircraft Configuration;Altitude Deviation;ATC Concern;Automation;Duty/Rest;EGPWS;Fatigue;Go Around/Missed;Maintenance;Miscellaneous;Navigation;Overspeed;Rejected Takeoff;Taxiway/Runway Incursion;TCAS;Unstable Approach;Wildlife;Windshear',
      description:  'This manages all the Event Types in the system.'
    )
    CustomOption.create(
      title:        'Event Venues',
      field_type:   'Checkbox',
      options:      'PAS;MAS;MOPS;OP;FRM;FA',
      description:  'This manages all the Event Venues in the system.'
    )
    CustomOption.create(
      title:        'Dispositions',
      field_type:   'Checkbox',
      options:      'Corrective Action;Delegate for General Safety Review;Electronic Response;Informal Action;Letter of Correction;Letter of No Action;No Action;Open Investigation;Voluntary Self-Disclosure;Warning Notice',
      description:  'This manages all the Dispositions in the system.'
    )
    CustomOption.create(
      title:        'Company Dispositions',
      field_type:   'Checkbox',
      options:      'Corrective Action;No Action;Voluntary Self-Disclosure',
      description:  'This manages all the Company Dispositions in the system.'
    )
  end

  def self.down
    CustomOption.where(title: 'Event Types').destroy_all
    CustomOption.where(title: 'Event Venues').destroy_all
    CustomOption.where(title: 'Dispositions').destroy_all
    CustomOption.where(title: 'Company Dispositions').destroy_all
  end
end
