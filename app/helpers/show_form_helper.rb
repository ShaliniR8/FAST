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
  def prepare_panels(owner)
    btns = Hash.new(false).merge(owner.panel_btns)
    [].tap do |panels|
      CONFIG.object[owner.class.name][:panels].each do |panel|
        case panel
        when :attachments
          panels << {
            partial: '/panels/attachments',
            attachments: owner.attachments,
            show_btns: btns[:attachments]
          }
        when :comments
          if owner.comments.present?
            panels << {
              partial: '/panels/comments',
              comments: owner.comments.preload(:viewer)
            }
          end
        when :contacts
          if owner.contacts.present?
            panels << {
              partial: '/panels/contacts',
              contacts: owner.contacts,
              fields: Contact.get_meta_fields('show')
            }
          end
        when :costs
          if owner.costs.present?
            panels << {
              partial: '/panels/costs',
              costs: owner.costs
            }
          end
        when :findings
          if owner.findings.present?
            panels << {
              partial: '/panels/findings',
              findings: owner.findings,
              show_btns: btns[:findings]
            }
          end
        when :recommendations #WIP
          panels << {
            partial: '/recommendations/show_all',
            owner: owner,
            show_btn: false
          }
        when :requirements #WIP
          panels << {
            partial: '/audits/show_requirements',
            owner: owner,
            type: owner.class.name.downcase
          }
        when :risk_assessment #WIP
          risk_matrix = owner.risk_analyses
        when :signatures
          if owner.signatures.present?
            panels << {
              partial: '/panels/signatures',
              signatures: owner.signatures,
              fields: Signature.get_meta_fields('show')
            }
          end
        when :sms_actions #WIP
          panels << {
            partial: '/sms_actions/show_all',
            owner: owner,
            show_btn: false
          }
        when :tasks #WIP
          panels << {
            partial: '/ims/show_task',
            owner: owner,
            fields: SmsTask.get_meta_fields('show')
          }
        when :transaction_log
          if owner.transactions.present?
            panels << {
              partial: '/panels/transaction_log',
              transactions: owner.transactions.preload(:user, :owner) #owner is for get_user_name
            }
          end
        else
          Rails.logger.warn "Unknown Panel #{panel}; preparation unavailable (skipped)"
        end
      end
    end
  end

end
