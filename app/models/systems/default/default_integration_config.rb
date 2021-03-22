class DefaultIntegrationConfig



  ECCAIRS_Preferences = {

    # This information is from documented schema/Schema.xsd
    datatype_dictionary: {
      1   => 'to_s', #'string',
      2   => nil, #nil,
      3   => 'to_i', #'int',
      4   => 'to_f', #'decimal',
      5   => 'to_s', #'string', # value_list
      6   => nil, #'text',
      7   => nil, #nil,
      8   => 'to_s', #'string', # Latitude Decimal
      9   => 'to_s', #'string', # Longitude Decimal
      10  => 'to_s', #'string', # Resource Locator
      11  => nil, #nil,
      12  => 'to_s', #'string', # base64Binary
      13  => 'to_s', #'string', # base64Binary
      14  => "to_time.strftime('%Y-%m-%d')", #'date',
      15  => "to_time.strftime('%H:%M:%S')", #'time',
    }

  }

end
