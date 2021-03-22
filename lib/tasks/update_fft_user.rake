task :update_fft_user => :environment do

  object_user_map = {
    Record:           ['users_id'],
    CorrectiveAction: ['responsible_user_id', 'approver_id'],
    Audit:            ['responsible_user_id', 'approver_id'],
    Investigation:    ['responsible_user_id', 'approver_id'],
    Finding:          ['responsible_user_id', 'approver_id'],
    SmsAction:        ['responsible_user_id', 'approver_id'],
    Recommendation:   ['responsible_user_id', 'approver_id']
  }

  # Total = 4792
  # num of duplicate users = 4688
  # num of unique users = 17 (4705)
  # 87 users (17, 68)

  p "[info] Start updating"

  original_users = User.all.select { |x|
    x.id > 3000 &&
    x.id < 30000 &&
    User.where(employee_number: x.employee_number).size > 1
  }

  total = original_users.size

  p "[info] FFT has #{total} duplicated users"
  p "======================================================"

  original_users.each_with_index do |user, index|

    p "------------------------------------------------------"
    duplicated_users = User.where(employee_number: user.employee_number)
    num_of_duplicated = duplicated_users.count
    original_user = duplicated_users[0]

    (num_of_duplicated - 1).times do |i|
      duplicated_user = duplicated_users[i + 1]
      next if duplicated_user.employee_number.nil?

      object_user_map.each do |key, value|
        object_name = key
        user_columns = value

        user_columns.each do |column|

          objects = Object.const_get(object_name).all.select { |x| x.send(column) == duplicated_user.id }
          p "[info] #{object_name}: User: #{duplicated_user.full_name}, #{column}" if objects.present?

          # Update user id
          objects.each do |object|
            p "[info] Update #{object_name} ##{object.id}'s user to #{original_user.id} from #{duplicated_user.id}"

            object.update_attributes(column.to_sym => original_user.id)
            object.save
          end

        end
      end

      # REMOVE duplicated users
      p "[info] (#{index}/#{total}) REMOVE User ##{duplicated_user.id}"
      duplicated_user.delete
    end
  end

  p "[info] DONE"
end


task :update_transactions => :environment do

  object_names = %W(Submission Record Report Investigation Finding Recommendation CorrectiveAction Audit)
  total = Transaction.all.size
  p "[START]"

  object_names.each do |object_name|

    p "[info] Updating #{object_name}"
    transactions = Transaction.all.select { |x| x.owner_type == object_name}


    transactions.each do |transaction|
      p "------------------------------------------------------"

      # Find user
      begin
        user = User.where(poc_id: transaction.user_poc_id).first
        if user.nil?
          p "[warn] User poc_id ##{transaction.user_poc_id} does not exist"
          next
        end
      rescue
        p "[warn] User poc_id ##{transaction.user_poc_id} does not exist"
        next
      end
      # Find owner
      begin
        owner = Object.const_get(object_name).where(obj_id: transaction.owner_obj_id).first
        if owner.nil?
          p "[warn] #{object_name} obj_id ##{transaction.owner_obj_id} does not exist"
          next
        end
      rescue
        p "[warn] #{object_name} obj_id ##{transaction.owner_obj_id} does not exist"
        next
      end


      # Update
      transaction.users_id = user.id
      transaction.owner_id = owner.id
      transaction.save
      p "[info] #{transaction.id}/#{total}: Update user_id: #{user.id} & #{object_name}_id: #{owner.id}"

    end

  end
  p "[DONE]"
end
