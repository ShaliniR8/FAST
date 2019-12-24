 module ShowFormHelper
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
    CONFIG.object[owner.class.name][:panels].values.select{ |data|
      data[:visible].call(owner: owner, user: current_user, **op)
    }.map { |data|
      {
        partial: data[:partial],
        show_btns: data[:show_btns].call(owner: owner, user: current_user, **op),
        **data[:data].call(owner: owner, user: current_user, **op)
      }
    }
  end

end
