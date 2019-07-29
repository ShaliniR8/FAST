class SCX_Config

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_KEY = {
    key_name: 'SCX',
    portals: [
      { label: 'Sun Country',          subdomain: 'scx' },
      # { label: 'Sun Country Training', subdomain: 'scx-training' },
    ]
  }

  def self.airline_config
    {
      :version                                        => "1.0.3",

      :name                                           => 'Sun Country Airlines',
      :code                                           => "SCX",
      :base_risk_matrix                               => false,
      :event_summary                                  => false,
      :event_tabulation                               => false,
      :enable_configurable_risk_matrices              => false,
      :allow_set_alert                                => false,
      :has_verification                               => false,
      :has_extension                                  => false,
      :has_mobile_app                                 => false,
      :enable_mailer                                  => true,
      :time_zone                                      => 'Central Time (US & Canada)',
      :enable_sso                                     => true,

      # Safety Reporting Module
      :submission_description                         => true,
      :submission_time_zone                           => true,
      :enable_orm                                     => false,
      :observation_phases_trend                       => false,
      :allow_template_nested_fields                   => false,
      :checklist_version                              => '3',

      # Safety Assurance Module
      :allow_reopen_report                            => true,
      :has_root_causes                                => true,
      :enable_recurrence                              => true,
      :enable_shared_links                            => false,


      # SMS IM Module
      :has_framework                                  => false,
    }
  end



  FAA_INFO = { #CORRECT/REVISE
    "CHDO"=>"FAA Flight Standards District Office, 300W 36th Ave, Suite 101, Anchorage, AK, 99503",
    "Region"=>"Anchorage",
    "ASAP MOU Holder Name"=>"N/A",
    "ASAP MOU Holder FAA Designator"=>"N/A"
  }

  MATRIX_INFO = {
    severity_table: {
      starting_space: true,
      column_header: ['1','2','3','4','5'],
      row_header: [
        'Accident or Incident',
        'Employee/Customer Injury',
        'Assets',
        'Operational Events',
        'Airworthiness',
        'Brand',
        'Customer',
        'Environment',
        'Security',
        'Regulatory',
        'System or Process',
        'Audit Finding',
        'OSHA'
      ],
      rows: [
        [ #Accident or Incident
          'Accident with serious injuries or fatalities; or significant damage to aircraft or property',
          'Serious incident with injuries and/or substantial damage to aircraft or property',
          'Incident with minor injury and/or minor aircraft or property damage',
          'incident with less than minor injury and/or less than minor damage',
          'No relevant safety risk'
        ],
        [ #Employee/Customer Injury
          'Fatality or serious injury with total disability/loss of capacity',
          'Immediate admission to hospital as an inpatient and/or partial disability/loss of capacity',
          'Injury requiring ongoing treatment, with no permanent disability/loss of capacity',
          'Minor injury not resulting in an absence',
          'No injury risk'
        ],
        [ #Assets
          'Multiple Aircraft OTS > 24 hours',
          'One aircraft OTS > 24 hours',
          'Aircraft OTS 2 to 24 hours',
          'Aircraft OTS < 2 hours',
          'No Aircraft OTS'
        ],
        [ #Operational Events
          'Loss of aircraft; beyond crew capability, operating with no meaningful safety margins',
          'Physical distress/high workload impairing the accuracy and completion of tasks',
          'Large reduction in safety margins; reduction in ability of crew to cope with adverse operating conditions',
          'Operation beyond operating limitations; Use of abnormal procedures',
          'No effect on operational safety'
        ],
        [ #Airworthiness
          'Returning an aircraft to service and operating it in a non-standard, unairworthy, or unsafe condition',
          'Returning an aircraft to service and operating it in a non-standard but not unsafe condition',
          'Returning an aircraft to service in a non-standard condition, but not operating it',
          'Affecting aircraft or systems reliability above established control limits but no affect on airworthiness or the safe operation of the aircraft',
          'No effect on airworthiness'
        ],
        [ #Brand
          'Extended negative national media coverage resulting in a substantial change in public opinion of Sun Country',
          'Short term negative media/internet activity resulting in minor change in public opinion of Sun Country',
          'Short term negative media/internet activity resulting in no change in public opinion of Sun Country',
          'Isolated negative media/internet activity resulting in no change in public opinion of Sun Country',
          'No negative media/internet activity',
        ],
        [ #Customer
          "<b><center>Extreme Customer Dissatisfaction</b></center>More than 500 customers affected for 48 hours or more",
          "<b><center>Customer Dissatisfaction</b></center>More than 500 customers affected for 3 to 48 hours",
          "<b><center>Customer Annoyance</b></center>Less than 500 customers affected for 3 to 48 hours",
          "<b><center>Isolated Customer Annoyance</b></center>Less than 500 customers affected for up to 3 hours",
          'No customer disruptions'
        ],
        [ #Environment
          "Severe Danger to Environment:<br />Large, significant waste of resources and emissions into water, air, or soil",
          'Medium significance in waste of resources and emissions into water, air, or soil',
          'Small significance in waste of resources and emissions into water, air, or soil',
          'Small waste or emission, no relevant risk of pollution',
          'No relevant risk of pollution, no spill but an undesirable situation'
        ],
        [ #Security
          'Loss of aircraft or death of Sun Country employee due to successful attack, terrorist activity, or civil unrest',
          'Security threat is genuine. Situation can only be resolved by handing control to outside agencies',
          'Security threat is genuine. Situation is only mitigated/resolved with assistance of outside agencies',
          'Security threat is genuine but can be mitigated or resolved by Sun Country',
          'Security threat is a hoax'
        ],
        [ #Regulatory
          "<center><b>Major Regulatory Deviation</b></center>Loss of company approvals, permits or certificates, resulting in the suspension of all operations",
          "<center><b>Moderate Regulatory Deviation</b></center>Loss of company approvals, permits or certificates, resulting in suspension in part of Sun Country operations",
          "<center><b>Minor Regulatory Deviation</b></center>Major breach of company policy or SOPs with no direct impact on approvals, permits or certificates, with a significant negative effect of ability to manage operations. Attitude of regulatory authority towards Sun Country has been negatively impacted",
          "<center><b>Policy/Procedure Deviation</b></center>Breach of company policy or SOPs, with no direct impact on approvals, certificates, permits, with a minor effect of ability to manage operations. Falls below industry \"best practices\"",
          "No breach of company requirements; No impact on approvals or permits"
        ],
        [ #System or Process
          'Loss or breakdown of entire system, subsystem or process',
          'Partial breakdown of a system, subsystem, or process',
          'System deficiencies leading to poor reliability or disruption',
          'Little to no effect on system, subsystem, or process',
          'No impact on system, subsystem, or process'
        ],
        [ #Audit Finding
          'Safety of Operations in Doubt',
          'Non-Compliance with company policy or CFR',
          'Non-conformance with company policy or CFR',
          'Audit Observation',
          'No findings or observations'
        ],
        [ #OSHA
          'Willful',
          'Repeat',
          'Serious',
          'General/Other',
          'No breach of OSHA requirements'
        ]
      ] #End of rows
    },

    severity_table_dict: {
      0 => '1',
      1 => '2',
      2 => '3',
      3 => '4',
      4 => '5'
    },

    probability_table: {
      starting_space: true,
      row_header: ['A', 'B', 'C', 'D'],
      column_header: ['Reactive Assessment (Control Effectiveness)', 'Proactive Assessment (Likelihood)'],

      rows: [
        [ #A
          "<center><b>Not Effective</b></center>Remaining controls were ineffective or no controls remained. The only thing preventing an accident were luck or exceptional skill, which is not trained or required",
          "<center><b>Likely to Occur</b></center>(Will occur in most circumstances, not surprised if it happens) or occurs > 1 in 100"
        ],
        [ #B
          "<center><b>Minimal</b></center>Some controls were left but their total effectiveness was minimal",
          "<center><b>Possible to Occur</b></center>(Might occur in some circumstances) or occurs > 1 in 1,000"
        ],
        [ #C
          "<center><b>Limited</b></center>An abnormal situation, more demanding to manage, but with still a considerable remaining safety margin",
          "<center><b>Unlikely to Occur</b></center>(Could occur in some circumstances, surprised if it happens) or occurs in > 1 in 10,000"
        ],
        [ #D
          "<center><b>Effective</b></center>Consisting of several good controls",
          "<center><b>Rare to Occur</b></center>(May occur but only in exceptional circumstances, may happen but it would only be highly unexpected) or occurs > 1 in 1,000,000"
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D'
    },

    risk_table: {
      starting_space: true,
      column_header: ['1','2','3','4','5'],
      row_header: ['A', 'B', 'C', 'D'],
      rows: [
        ["crimson",     "crimson",      "coral",          "yellow",         "mediumseagreen"      ],
        ["crimson",     "coral",        "yellow",         "steelblue",      "mediumseagreen"      ],
        ["coral",       "yellow",       "steelblue",      "mediumseagreen", "mediumseagreen"      ],
        ["yellow",      "steelblue",    "mediumseagreen", "mediumseagreen", "mediumseagreen"      ],
      ]
    },

    risk_table_dict: {
      crimson:        'Red (A/1, A/2, B/1) - High',
      coral:          'Orange (A/3, B/2, C/1) - Serious',
      yellow:         'Yellow (A/4 B/3, D/1) - Moderate',
      steelblue:      'Blue (B/4, C/3, D/2) - Minor',
      mediumseagreen: 'Green (A/5, B/5, C/4, C/5, D/3, D/4, D/5) - Low',
    },

    risk_table_index: {
      crimson:        "High",
      coral:          "Serious",
      yellow:         "Moderate",
      steelblue:      "Minor",
      mediumseagreen: "Low"
    },

    risk_definitions: {
      crimson:          { rating: 'High',      cells: 'A/1, A/2, and B/1',                      description: '' },
      coral:            { rating: 'Serious',   cells: 'A/3, B/2, and C/1',                      description: '' },
      yellow:           { rating: 'Moderate',  cells: 'A/4, B/3, and D/1',                      description: '' },
      steelblue:        { rating: 'Minor',     cells: 'B/4, C/3, and D/2',                      description: '' },
      mediumseagreen:   { rating: 'Low',       cells: 'A/5, B/5, C/4, C/5, D/3, D/4, and D/5',  description: '' }
    }
  }

  SAML_DATA = {
    # Always ask if they have a URL for their metadata
    # If they do, you can skip all tags under IdP Info and use the following- otherwise leave this string empty: ''
      metadata_link: 'https://syextec0001.suncountry.com/FederationMetadata/2007-06/FederationMetadata.xml',

    ### IdP Info ###

      # Route to IdP; should be in metadata.xml under:
       # <EntityDescriptor ... entityID="|__this__|" />
      idp_entity_id: 'https://SYEXTEC0001.suncountry.com/adfs/services/trust',

      # Route to IdP's sign-in; should be in metadata.xml under:
       # <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="|__this__|" />
      idp_sso_target_url: 'https://syextec0001.suncountry.com/adfs/ls/',


      # Specifies the route to the hash algorithm; standard format is sha1, s"http://www.w3.org/2000/09/xmldsig#sha1"

      ### Fingerprint Config ###

        # Fingerprint is less safe than the full certificate- only set to true and provide settings if needed
        use_fingerprint: false,

        # Value of fingerprint; should be in metadata.xml
        idp_cert_fingerprint: '',

        # Route to hash algorithm- standard is SHA1, you shouldn't have to alter this:
        idp_cert_fingerprint_algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1',

      ### Certificate Config ###
        # This will be used in place of the fingerprint and is more secure
        # If only on certificate, place it under signing_cert
        # Do NOT include BEGIN-END tags on the certificates

        # Certificate used for signing the response
        signing_cert:     'MIIC8DCCAdigAwIBAgIQHXFgSsDwt7JHI7Qtyk1zUjANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylBREZTIFNpZ25pbmcgLSBTWUVYVEVDMDAwMS5zdW5jb3VudHJ5LmNvbTAeFw0xNjEwMTIxNDE3MDBaFw0xOTEwMTIxNDE3MDBaMDQxMjAwBgNVBAMTKUFERlMgU2lnbmluZyAtIFNZRVhURUMwMDAxLnN1bmNvdW50cnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4tUOjmp4Vfsxbf/u0G/sYXkjQ2edUE3A1BqZSA/LT0TCq4czSQCEwaoZcAL5juwKrtItXxX6XeXaXggpAjgjrxpircCRJzsUdNAcbPJtWDP6tE0c6OXBaYgGhoxIZOPhv8Ohh9iyF/k9EVMazZayz4QgTKBTD254RVxGprmwTd7F1oeiVfigESSViDA5ErN3BRGOppqWZ3c6U4XqNieA59dle3bFqv0oS0bmoU8dx/RQXNgdHCRXTJBatPs4Q45am1had9IJwzcZXajwDo8kZC+f9usZd0bHGd8vC32FZLtcF38nNoV9gwXgdqVEfwd8Cb5GMK3KclyRd8cXTXhCAQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQCY7Dqjv3pHjhqf6TI55t6PWwkXHtBgutsGlZAdekFvKOsKjScspoDAN5cqV1akRq4v7Zy+ib6wE2uLC+8Ry4jBv1Yo+bSXz+9z4h7MVvXPCQiW30bL/OMi6/XtctLBHywVNzCcqissN9ymGzsRxXnvUmoiOovbVpDG6MDgBBBsGn1g4KOkdyT83iqqYlLrtjXm/ruAqjLG8tUlU1NyIhXKzpcFYI9gc3AMDS4vXIOAzW2SBiXzxfIHXFkT8u9RnYQ4dG1uQtMTVGT882TkkGgfMvJtJv7zAm4CXk+4qLzoOb+Zl5NoswPfe9GSwGk880uucA6MG5kqPubw6HgJAHLi',
        # Certificate used for encrypting the response
        encryption_cert:  'MIIC9jCCAd6gAwIBAgIQKQFFKDf7WJRKo/DuHm/DTzANBgkqhkiG9w0BAQsFADA3MTUwMwYDVQQDEyxBREZTIEVuY3J5cHRpb24gLSBTWUVYVEVDMDAwMS5zdW5jb3VudHJ5LmNvbTAeFw0xNjExMjAxNjU3MDFaFw0xOTExMjAxNjU3MDFaMDcxNTAzBgNVBAMTLEFERlMgRW5jcnlwdGlvbiAtIFNZRVhURUMwMDAxLnN1bmNvdW50cnkuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3QkCaMeyXDSxiuQ23MeUfLOkuMld9rm39rNaTtZL40Xzjlw55HWP78tYoEIEqzAxciwTyDVX3RDbhy9cFavT8cifcRNNUx5iF4kFD+KOxrtB3IU3aocHPJNxJxzgF854rDFRZFzYwyUxC/rbmgI1HbUDbXVinPbg15iUACZGaReMP77n8mdEWLWzkDnd0Ef4MsBP45m+l8SDUchORw9R7FpRGZ+VoIEhxwSI7/hdlBQXDpk6TfCEhhwXKt4wjYeLFhqaOfaPXREpXzdM0u1iCE24OREHC/zcB1SuGK8aANAm2gYQ47N1XWXbIDP3cFwCIPXVo1L6blM7T7AZ+qfg+QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQC0PdDA8IfcFYcGyOJKniZEsegQP2EORFTA6F1ONGDfB8hJWzxGa2072cqtxLljH6baeJqr9rvMQDxYGs99ZjA2z5Uv2mSSu70aJo40DAdhfaPWUpoetQMwIHBr83l1+JFGgK973JjvEDHpanupkgAC8oWuMdAZDmt9eF8jAdR468MTxY+ySb6b+nMcUet8jNWJgOQyOxGVdSz3ixGaev8Q3b1Fzr41xgS+t7TClUUwlSOOiRBr0e37nWlq6BbgwrsHC9A1xUm1AVJ4Hl9/CqaSpV95RGQFyA5dDEDyHZ+Uk7qtg2Z6Xluqowhc3mpPaBNY3jzO8pSkqPkIJcAE5s1p',
    ### END IdP Info ###

    ### Base Access Routes for this implementation ### - You shouldn't have to alter these
      response_consume_url: '/saml/consume',
      issuer_metadata_url:  '/saml/metadata',
      issuer_logout_url:    '/saml/logout',

    ### Data Request information
      #This determines the format of the identifying information
      name_id_format:    'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress', # "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified",

    # Security

    ### Critical IdP links:

      # Location to send SAML request from ProSafeT, should be in the following format:
      # "|__IdP_domain__|/adfs/ls/idpinitiatedsignon"
      access_point: 'https://syextec0001.suncountry.com/adfs/ls/idpinitiatedsignon',

      # Route to IdP's sign-out; should be in the following format:
      # '|__IdP_domain__|/adfs/ls/?wa=wsignout1.0'
      idp_slo_target_url: 'https://syextec0001.suncountry.com/adfs/ls/?wa=wsignout1.0',
  }
  #The following must also be defined for SSO: This interprets the IdP's response info and matches it to an account
  def self.digest_response(response)
    #Unique digest statement to find user-identifying email from IdP:
    # Rails.logger.debug "######## SSO IMPLEMENTATION DATA ########\n nameid: #{response.nameid}\n attributes: #{response.attributes.to_h}"
    user = User.where(sso_id: response.nameid).first
    if user.nil?
      Rails.logger.info "SSO ERROR: Could not find user with SSO ID #{response.nameid}"
    end
    user
  end

  ULTIPRO_DATA = {
    filepath: '/home/jiaming/dylan/Ultipro_POC.xml',
    #This is to compare the new file with the prior file
    filepath_prior: '/home/jiaming/dylan/Ultipro_POC_prior.xml',
    expand_output: false, #Shows full account generation details
    dry_run: false, #Prevents the saving of data to the database

    #The following identifies what account type is associated with each employee-group
    group_mapping: {
      'dispatch'    => 'Analyst',
      'fight-crew'  => 'Pilot',
      'ground'      => 'Ground',
      'maintenance' => 'Staff',
      'other'       => 'Staff'
    }, #Cabin
    tracked_privileges: [
      'Ground: Incident Submitter',
      'Ground: General Submitter',
      'Other: General Submitter',
      'Flight Crew: ASAP Submitter',
      'Flight Crew: Incident Submitter',
      'Flight Crew: Fatigue Submitter',
      'Dispatch: ASAP Submitter',
      'Dispatch: Incident Submitter',
      'Dispatch: Fatigue Submitter',
      'Maintenance: ASAP Submitter',
      'Maintenance: Incident Submitter',
      'Maitnenance: Fatigue Submitter',
      'Cabin: ASAP Submitter',
      'Cabin: Incident Submitter',
      'Cabin: Fatigue Submitter'
    ],
  }

#ALL FOLLOWING MAY NEED CORRECTION/REVISION

  # Calculate the severity based on #{BaseConfig.airline[:code]}'s risk matrix
  def self.calculate_severity(list)
    if list.present?
      list.delete("undefined") # remove "undefined" element from javascript
      return list.map(&:to_i).min
    end
  end

  # Calculate the probability based on #{BaseConfig.airline[:code]}'s risk matrix
  def self.calculate_probability(list)
    if list.present?
      list.delete("undefined") # remove "undefined" element from javascript
      return list.map(&:to_i).min
    end
  end

  def self.print_severity(owner, severity_score)
    MATRIX_INFO[:severity_table_dict][severity_score] unless severity_score.nil?
  end

  def self.print_probability(owner, probability_score)
    MATRIX_INFO[:probability_table_dict][probability_score] unless probability_score.nil?
  end

  def self.print_risk(probability_score, severity_score)
    Rails.logger.debug "Probability score: #{probability_score}, Severity score: #{severity_score}"
    if !probability_score.nil? && !severity_score.nil?
      lookup_table = MATRIX_INFO[:risk_table][:rows]
      return MATRIX_INFO[:risk_table_index][lookup_table[probability_score][severity_score].to_sym]
    end
  end



end
