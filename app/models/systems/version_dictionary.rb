class VersionDictionary
  VERSIONS = [
    {
      title: 'Version 1.2.6',
      tag: 'New',
      toggle: 'v1_2_6',
      date: '01/28/2021',
      sections: {
        'What\'s New' => [
          'Added Auto-Save functionality to Submissions. Auto-Saved submissions can be found in the In Progress tab',
          'Added ability to discard in progress submissions so that auto-saved submissions can be discarded',
          'Added Included Findings column to Inspections index, Evaluations index and Investigations index',
          'Added ability to attach PDF in email notification sent from messages',
          'Added ability to add an Event to a Meeting directly from the event display page',
          'Added ability to save large pieces of text in Verification Details and Verification comment boxes',
          'Added ability to save large pieces of text in SMS Actions comment boxes',
          'Added a separate page for listing disabled users',
          'Added Root Cause to Investigations',
        ],
        'Optimizations & Fixes' => [
          'Optimized loading times of index pages containing a lot of records',
          'Optimized saving and handling of large templates and checklists',
          'Closed reports will now have a closed tag shown on the Dashboard Calendar',
          'Updated the simulation label so that it does not cover up the form buttons',
          'Upon access denial, users will be redirected back to the page they were browsing',
          'Fixed issue where events having many reports could not be added to meetings',
          'Addressing Checklist will now open the checklist on the same page to avoid out-of-sync inconsistencies',
          ]
      }
    },

    {
      title: 'Version 1.2.5',
      toggle: 'v1_2_5',
      date: '12/18/2020',
      sections: {
        'What\'s New' => [
          'Added ability to enforce required property on checkboxes and radio button fields',
          'Added ability to enforce minimum number of options to be selected for checkboxes',
          'Added ability to add nested fields to radio buttons and checkboxes',
          'Added ability to edit airport and employee fields from the edit individual category panel',
          'Added ability to set up automated notifications for Verifications and Meetings',
        ],
        'Optimizations & Fixes' => [
          'Auto-expansion for text-areas to allow for longer narratives',
          'Placeholder texts added to checklist textboxes so that template creators and addressees can understand the purpose of the field better',
          'Events listed in any meeting display page will now be sorted from oldest to newest',
          ]
      }
    },

    {
      title: 'Version 1.2.4',
      toggle: 'v1_2_4',
      date: '11/24/2020',
      sections: {
        'What\'s New' => [
          'Added Report Type in Event listing',
          'Added Meeting Agenda Tooltip in Meetings',
          'Added Launched SRA/Investigation in Meeting',
          'Added Checklist Findings in Findings List'
        ],
        'Optimizations & Fixes' => [
          'Optimized Report processing workflow',
          'Improved Report page load speed',
          'Improved PDF generation speed',
          'Improved FAA Report accuracy'
          ]
      }
    },

    {
      title: 'Version 1.2.3',
      toggle: 'v1_2_3',
      date: '10/14/2020',
      sections: {
        'What\'s New' => [
          'Added Series visualization and drill down to Query Center.',
          'Revised Checklist formatting and added table/page view.',
          'Attach Findings to checklist rows.',
          'Auto save on address checklist.',
          'Added more content + page numbering and new look to PDF.',
          'Added auto-close/default status feature to Reports/Templates.',
          'Custom Options for Event Title.',
          'Extension Request and Verification delete buttons.',
        ],
        'Optimizations & Fixes' => [
          'Fixed Submission/Template nested fields related issue.',
          'Improved Submission/Template layout.',
          'Simplified user account types.',
          'Fixed some FAA Report information not showing correctly.',
          'Improved formatting on FAA Reports.',
          'New look for Risk Matrix.',
          ]
      }
    },
    {
      title: 'Version 1.2.2',
      toggle: 'v1_2_2',
      date: '8/21/2020',
      sections: {
        'What\'s New' => [
          'Added Additional Info column to Report table.',
          'Added Launch functionalities from SA to SRM module.',
          'Added due date to Verifications column in Corrective Action table.',
          'Added assigning multiple Verification Validators.',
          'Added message content to email notifications.',
          'Added Category/Root Cause to Report/Event PDF.',
          'Added Meeting Type to Meeting and Meeting table.',
          'Added Delete functionality for Meeting Agenda.'
        ],
        'Optimizations & Fixes' => [
          'Fixed Advanced Search for Submitted By in Report table.',
          'Fixed nested panels display.',
          'Improved date and time accuracy.',
          'Updated Meeting Minutes and Agenda to show in all Meetings.'
          ]
      }
    },
    {
      title: 'Version 1.2.1',
      toggle: 'v1_2_1',
      date: '3/31/2020',
      sections: {
        'What\'s New' => [
          'Added Tab view on all pages.',
          'Added Advanced Search back on all pages.',
          'Added configurable Max Character Count for Text Area field in Safety Reports Templates.',
          'Added Edit/Delete functionalities for Costs, Contacts, Comments, and Tasks.'
        ],
        'Optimizations & Fixes' => [
          'Updated list of Time Zone options and displaying time with time zone.',
          'Fixed viewing privileges on access control rules page',
        ]
      }
    },
    {
      title: 'Version 1.2.0',
      toggle: 'v1_2_0',
      date: '2/11/2020',
      sections: {
        'What\'s New' => [
          'Added Stacked and Line chart options to Query Center.',
          'Added Series capability to Query Center.',
          'Added Distribution List feature to Message Center.',
          'Added Verification to various forms',
          'Added Department to Dashboard filter',
          'Added View All and Mark All as Read functionalities to News.',
          'Added Tab view on Reports and Events page',
        ],
        'Optimizations & Fixes' => [
          'Updated Close Report form content',
          'Updated Root Cause Analysis UI.',
          'Fixed Calendar displaying issue for Meetings',
          'Fixed Dashboard stats for overdue items inaccurate issue',
        ]
      }
    },
    {
      title: 'Version 1.1.3',
      toggle: 'v1_1_3',
      date: '12/6/2019',
      sections: {
        'What\'s New' => [
          'Added tooltips to Meeting.',
          'Added Root Causes to Reports.',
          'Added Root Causes to Findings.',
          'Added title to Automated Notifications for Meetings',
          'Added Department to Hazards and Risk Controls.',
          'Added Department to SRA(SRM) Dashboard filter.',
          'Added confirmation email for new submissions.',
          'Messaging the Submitter from Submissions now adds a transaction in the log.',
        ],
        'Optimizations & Fixes' => [
          'Revised version tracking and version history UI.',
          'Revised signature in all email notifications.',
          'Replaced engineering@prosafet.com with donotreply@prosafet.com for sender in all email notifications.',
          'Fixed issue with Under Review Events not being visible in "Add Event" meeting button.',
          'Fixed issue with ORM Template Modal not being dismissed.',
          'Fixed issues with Query Center breaking on module change.',
          'Fixed Admins from seeing submitted by, rather than only Global Admins.',
          'Fixed CC-only internal messages from breaking when no To was supplied.',
          'Events ordered by ID in Meeting PDFs.',
        ]
      }
    },
    {
      title: 'Version 1.1.2',
      toggle: 'v1_1_2',
      date: '11/4/2019',
      sections: {
        'What\'s New' => [
          'Added "Actual Completion/Close Dates" to Audits, Investigations, Evaluations, Inspections, Corrective Actions, and Recommendations.',
          'Added support for extremely large checklists in Safety Assurance.',
          'Index pages now have 50 and 100 entry options.'
        ],
        'Optimizations & Fixes' => [
          'More Airports have been added to the Airport List.',
          'Optimizations to data storage.',
          'Varied minor fixes.'
        ]
      }
    },
    {
      title: 'Version 1.1.1',
      toggle: 'v1_1_1',
      date: '9/27/2019',
      sections: {
        'What\'s New' => [
          'Safety Reporting Events can now be assigned to multiple Meetings.',
          'Meetings now have titles.',
          'Meetings display timezones for review period and meeting hours.',
          'Users can now message submitters on Anonymous Reports while maintaining anonymity.',
          'Root Causes can now be added to Events.',
          'Added option to message anonymously to Message Center.',
          'More videos added to User Guides.'
        ],
        'Optimizations & Fixes' => [
          'Increased control over Event data restriction.',
          'Improved Mobile App integration.',
          'Fixed interface elements in Meetings.',
          'Updated Interface for Single Sign-On Systems.',
        ],
      }
    },
    {
      title: 'Version 1.1.0',
      toggle: 'v1_1_0',
      date: '8/12/2019',
      sections: {
        'What\'s New' => [
          'New Recurring Audits, Inspections, and Evaluations.',
          'Added Schedule Verifications and Request Extensions to Corrective Actions.',
          'Added Digital Signatures to Safety Assurance.',
          'SRAs and Investigations now launchable from Events.',
          'Updated closing Report from Event workflow.',
          'Automatic redirect to home page based on access.',
          'New User Guides page.',
          'New Smart Form for Safety Reports Templates.',
          'Queries and Visualizations can now be saved.',
          'Added delete and copy buttons to Query.',
          'Updated Query search bar.',
        ],
        'Optimizations & Fixes' => [
          'Improved site security and access verifications..',
          'Fixed display issues with Anonymous submitter.',
          'Improved load speed for all pages.',
          'Fixed issues with group access.',
          'Updated Events UI.',
          'Updated Risk Assessment UI across all modules.',
          'Various Transaction Log optimizations.',
          'Fixed issues with SRM Meetings workflow.',
        ],
      }
    },
    {
      title: 'Version 1.0.3',
      toggle: 'v1_0_3',
      date: '5/31/2019',
      sections: {
        'What\'s New' => [
        'New Query Center for all modules.',
        'Added feature for controlling anonymous submission.',
        'Added customizable Automated Notifications.',
        'Added in FAA Reports: Corrective Actions and Safety Enhancements.',
        'Color coded active/inactive users for Events and Meetings pages.',
        'Close an Event directly from a Meeting.',
        'Revised the workflow process.',
        'Added Override Status for Admin.',
        'Added links to Source of Input.',
        'Email notify for all submissions.',
        ],
        'Optimizations & Fixes' => [
          'Grouped all configuration to <b>System Configuration</b> menu.'.html_safe,
          'Improved load speed on Dashboard in all modules.',
          'Updated print PDF views.',
          'Improved Submission form UI.',
          'Intuitive grouping of Rules.',
          'New look for dashboard notifications.',
          'Added “Tooltip” and “Instructions” on several pages.',
          'New buttons/layout for Events and Meetings.',
          'Improved Message Inbox look and ability to link items in Message.',
        ],
      }
    },
    {
      title: 'Version 1.0.2',
      toggle: 'v1_0_2',
      date: '10/3/2018',
      sections: {
        'What\'s New' => [
          '“Reopen” functionality for Reports, Events, and Meetings.',
          'Added “Tooltip” and “Instructions” on several pages.',
          'Admin users can now simulate logging in as other users.',
          'Color coded risk factors on reports listing pages. ',
          'Download FAA report in word/docx format.',
          'User configurable message templates.',
        ],
        'Optimizations & Fixes' => [
          'New look for Template editing page.',
          'New look for Query and Analytics page.',
          'New look for Risk Assessment section across all modules.',
          'New look for account management page.',
          'Updated visual design for all grids and tables.',
          'Faster Dashboard loading speed.',
          'Minor bug fixes and usability improvements.',
        ],
      }
    },
    {
      title: 'Version 1.0.1',
      toggle: 'v1_0_1',
      date: '5/9/2018',
      sections: {
        'What\'s New' => [
          'Added in Templates: Deletion and Re-ordering of Categories.',
          'Added in Templates: Deletion and Re-ordering of Fields.',
          'Added in Templates: Fields can now be tagged as Required.',
          'Added "View Narrative" to meeting. Allows user to quickly read Narratives.',
          'Added capability to search for a range of date/time.',
          'Added Reopen functionality for all Safety Assurance reports.',
          'Added functionality for submitter to choose whether to file an ASAP with Incident submission',
          'Added Dashboard Analytics filter to all four modules.',
          'Added Query and Analytics to Safety Reporting Module.',
          'Added Forgot Password functionality.',
        ],
        'Optimizations & Fixes' => [
          'Bug fix: Mobile devices compatibility with Time Zone toggling and Date/Time picker.',
          'Updated Submit/Save button to prevent multiple submissions.',
          'Added confirmation message on creation/modification of reports.',
          'Added confirmation alerts for certain button clicks.',
        ],
      }
    },
  ]

end
