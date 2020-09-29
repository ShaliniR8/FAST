 module ShowDataHelper
  #This contains all helpers used to render generalized show/form pages

  #Called in form/render_buttons; pass the owner and form location to automatically find which
    #buttons should be displayed
  def prepare_btns(owner, env, **op)
    actions = CONFIG.object[owner.class.name][:actions].select{ |key, act|
       act[:btn_loc].include?(env) &&
       act[:access].call(owner: owner, user: current_user, **op)
    }.map {|key, act| key}
    actions
  end

  #Called in panel/show_panels; pass the owner and it will initialize all locals for each panel
  def prepare_panels(owner, **op)
    panel_data = CONFIG.object[owner.class.name][:panels].values.select{ |data|
      data[:visible].call(owner: owner, user: current_user, **op) rescue nil
    }.map { |data|
      {
        partial: data[:partial],
        show_btns: data[:show_btns].call(owner: owner, user: current_user, **op),
        **data[:data].call(owner: owner, user: current_user, **op)
      }
    }
  end

  #Called in panel/print_panels; pass the owner and it will initialize all locals for each panel
  #skip_source is used to specify when to skip printing source of input
  #  this is used to prevent an infinite loop caused by printing
  #    an owner's children's source_of_input, which is owner
  def print_panels(owner, **op)
    hierarchy_object = CONFIG.object[owner.class.name]
    # are custom print_panels defined ? print the custom panels : print the default panels
    panels = hierarchy_object[:print_panels].present? ? :print_panels : :panels
    panel_data = hierarchy_object[panels]
    if panel_data.present?
      # skip SOI for launch items(sra, investigation)
      panel_data.delete(:source_of_input) if op[:launch_item]
      panel_data.values.select{ |data|
        data[:visible].call(owner: owner, user: current_user, **op) rescue nil
      }.map { |data|
        {
          print_partial: data[:print_partial],
          **data[:data].call(owner: owner, user: current_user, **op)
        }
      }
    else
      []
    end
  end

end
