class DefaultMobileConfig

  PORTALS =
  {
    #BSK Portals
    bsk_general:      { label: 'General',                       subdomain: 'bsk' },
    bsk_training:     { label: 'Training',                      subdomain: 'bsk-training' },

    #Demo Portals
    demo_general:     { label: 'General',                       subdomain: 'demo' },

    #Development Portals:
    dev3000:          { label: '<Dev 3000>',  subdomain: 'port=3000' },
    dev3001:          { label: '<Dev 3001>',  subdomain: 'port=3001' },
    dev3002:          { label: '<Dev 3002>',  subdomain: 'port=3002' },
    dev3003:          { label: '<Dev 3003>',  subdomain: 'port=3003' },
    dev3004:          { label: '<Dev 3004>',  subdomain: 'port=3004' },

    #NAMS Portals
    nams_general:     { label: 'General',                       subdomain: 'nams' },

    #SCX Portals
    scx_general_sso:  { label: 'Personal Device',               subdomain: 'scx',           sso: true },
    scx_general_dir:  { label: 'External User',                 subdomain: 'scx', },
    scx_shared_sso:   { label: 'Shared Device',                 subdomain: 'scx',           sso: true,  shared: true },
    scx_shared_dir:   { label: 'General (Shared) (ProSafeT)',   subdomain: 'scx',                       shared: true },
    scx_training_sso: { label: 'Training',                      subdomain: 'scx-training',  sso: true },
    scx_training_dir: { label: 'Training (ProSafeT)',           subdomain: 'scx-training', },
    scx_shrtrain_sso: { label: 'Training (Shared)',             subdomain: 'scx-training',  sso: true,  shared: true },
    scx_shrtrain_dir: { label: 'Training (Shared) (ProSafeT)',  subdomain: 'scx-training',              shared: true },

    #FFT portals
    fft_training_dir: { label: 'Training',                      subdomain: 'fft-training'},
    fft_training_sso: { label: 'Training SSO',                  subdomain: 'fft-training',  sso: true},

    #Trial Portals
    trial_general:    { label: 'General', subdomain: 'trial' },
  }

  # Mobile Keys are used for initializing the app to specific portals.
    # Note: These keys are not a direct security apparatus- this is a convenience tool to hide
     # elements from the user that they may mess with otherwise (distributes a config that has advanced settings)
  KEYS = {
    '[Admin Key]' => { # 0D03-579F-421F-E903
      key_name: 'Admin',
      portals: PORTALS.keys
    },

    'BSK Key' => { # F9A1-67E8-DC44-4D8C
      key_name: 'Miami Air International',
      portals: %i[bsk_general bsk_training]
    },

    'BSK Beta Key' => { # A6DE-FAB4-86B5-4FDA
      key_name: 'Miami Air International Training',
      portals: %i[bsk_training]
    },

    'Demo Key' => { # 353D-0FC5-E54E-9C2F
      key_name: 'Demo',
      portals: %i[demo_general]
    },

    'NAMS Key' => { # F3E3-60E8-84C2-24CF
      key_name: 'Northern Air Cargo',
      portals: %i[nams_general]
    },

    'SCX Key' => { # 33F1-4A88-339C-E6FD
      key_name: 'Sun Country Airlines',
      portals: %i[
        scx_general_sso
        scx_general_dir
        scx_shared_sso
      ]
    },

    'SCX Beta Key'=>{ # 35E1-98A2-2C8F-A912
      key_name: 'Sun Country Airlines Mobile Beta',
      portals: %i[
        scx_training_sso
        scx_training_dir
        scx_shrtrain_sso
        scx_shrtrain_dir
      ]
    },


    'FFT Beta Key' =>{ # EE6C-D7FB-19B0-8377
      key_name: 'Frontier Airlines Mobile Beta',
      portals: %i[
        fft_training_dir
        fft_training_sso
      ]
    },

    'Trial Key' => { # 6158-BC31-0338-233B
      key_name: 'Trial',
      portals: %i[trial_general]
    },

  }.map{ |key, value|
    value[:portals] = value[:portals].map{ |elem| PORTALS[elem] }
    [Digest::SHA2.hexdigest(key)[0..15], value]
  }.to_h

  # Put this into any ruby compiler to generate a human readable key
    # require 'digest'
    # key = '[Admin Key]'
    # puts Digest::SHA2.hexdigest(key)[0..15].upcase.scan(/.{4}/).join('-')

end
