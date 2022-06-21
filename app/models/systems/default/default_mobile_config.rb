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
    scx_shared_sso:   { label: 'Shared Company Device',         subdomain: 'scx',           sso: true,  shared: true },
    scx_shared_dir:   { label: 'General (Shared) (ProSafeT)',   subdomain: 'scx',                       shared: true },
    scx_training_sso: { label: 'Training',                      subdomain: 'scx-training',  sso: true },
    scx_training_dir: { label: 'Training (ProSafeT)',           subdomain: 'scx-training', },
    scx_shrtrain_sso: { label: 'Training (Shared)',             subdomain: 'scx-training',  sso: true,  shared: true },
    scx_shrtrain_dir: { label: 'Training (Shared) (ProSafeT)',  subdomain: 'scx-training',              shared: true },

    #FFT portals
    fft_training_dir: { label: 'Training',                      subdomain: 'fft-training'},
    fft_training_sso: { label: 'Training SSO',                  subdomain: 'fft-training',  sso: true},
    fft_dir:          { label: 'Login with ProSafeT',           subdomain: 'fft'},
    fft_sso:          { label: 'SSO',                           subdomain: 'fft',           sso: true},

    #ATN portals
    atn_training_dir: { label: 'Training',                      subdomain: 'atn-training'},
    atn_dir:          { label: 'General',                       subdomain: 'atn'},
    #atn_training_sso: { label: 'Training SSO',                  subdomain: 'fft-training',  sso: true},
    #atn_dir:          { label: 'Login with ProSafeT',           subdomain: 'fft'},
    #atn_sso:          { label: 'SSO',                           subdomain: 'fft',           sso: true},

    # RVF portals
    rvf_training_dir: { label: 'Training',                      subdomain: 'rvf-training'},
    rvf_dir:          { label: 'General',                       subdomain: 'rvf'},

    #RJET portals
    rjet_training_dir: { label: 'Training',                      subdomain: 'rjet-training'},
    rjet_training_sso: { label: 'Training SSO',                  subdomain: 'rjet-training',  sso: true},
    rjet_dir:          { label: 'Login with ProSafeT',           subdomain: 'rjet'},
    rjet_sso:          { label: 'SSO',                           subdomain: 'rjet',           sso: true},

    #RPA portals
    rpa_dir:          { label: 'Login with ProSafeT',           subdomain: 'rpa'},
    rpa_sso:          { label: 'SSO',                           subdomain: 'rpa',           sso: true},

    #Eulen Portals
    eulen_general_dir: { label: 'Login with ProSafeT', subdomain: 'eulen' },

    #SJO Portals
    sjo_general_dir: { label: 'Login with ProSafeT', subdomain: 'sjo' },

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
        scx_training_dir
        scx_training_sso
      ]
    },


    'FFT Beta Key' =>{ # EE6C-D7FB-19B0-8377
      key_name: 'Frontier Airlines Mobile',
      portals: %i[
        fft_dir
      ]
    },

    'FFT Key' =>{ # 4D25-BE28-93CA-8088
      key_name: 'Frontier Airlines',
      portals: %i[
        fft_sso
      ]
    },


    'ATN Beta Key' =>{ # 5D8F-3A12-1E33-0C4A
      key_name: 'Air Transport International Mobile Beta',
      portals: %i[
        atn_training_dir
      ]
    },
    'ATN Key' =>{ # EF23-C9BC-C96D-1417
      key_name: 'Air Transport International',
      portals: %i[
        atn_dir
      ]
    },


    'RVF Beta Key' =>{ # 5F85-7FC8-D717-84E8
      key_name: 'Ravn Alaska',
      portals: %i[
        rvf_training_dir
      ]
    },
    'RVF Key' =>{ # 0447-31ED-DF24-ABF9
      key_name: 'Ravn Alaska',
      portals: %i[
        rvf_dir
      ]
    },


    'RJET Beta Key' =>{ # 902A-3488-E2BB-4DE8
      key_name: 'Republic Airways Mobile Beta',
      portals: %i[
        rjet_training_sso
      ]
    },
    'RJET Key' =>{ # 2B6D-181E-AEE7-39AA
      key_name: 'Republic Airways',
      portals: %i[
        rjet_dir
        rjet_sso
      ]
    },


    'RPA Key' =>{ # 2A52-7296-251B-74E2
      key_name: 'Republic Airways',
      portals: %i[
        rpa_dir
        rpa_sso
      ]
    },

    'EULEN Key' =>{ # 8DD7-B9B3-F409-3A49
      key_name: 'Grupo Eulen',
      portals: %i[
        eulen_general_dir
      ]
    },

    'SJO Key' =>{ # D238-B9D1-1135-3381
      key_name: 'Juan Santamaría International',
      portals: %i[
        sjo_general_dir
      ]
    },


    'Trial Key' => { # B0A6-42C4-FFD3-A978
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
