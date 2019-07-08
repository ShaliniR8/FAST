namespace :version_1_0_3 do

  task :add_common_privileges => :environment do

    OBSERVATION_SUBMITTER_ID = 127 
    OBSERVATION_ANALYST_ID = 128
    CONCERN_SUBMITTER_ID = 129 
    CONCERN_ANALYST_ID = 130

    BEGIN_SUB_PRIV = 100
    END_SUB_PRIV = 104
    BEGIN_ANALYST_PRIV = 105
    END_ANALYST_PRIV = 109    

    #for each submitter privilege id
    for i in BEGIN_SUB_PRIV..END_SUB_PRIV 
      #get every association of the privilege
      roles = Role.where :privileges_id => i 
      roles.each do |r| 
        user_id = r.users_id
        #if role does not already exist
        #add role for the user
        if Role.where(:users_id => user_id, :privileges_id => OBSERVATION_SUBMITTER_ID).empty?
          Role.create :users_id => user_id, :privileges_id => OBSERVATION_SUBMITTER_ID
        end
        if Role.where(:users_id => user_id, :privileges_id => CONCERN_SUBMITTER_ID).empty?
          Role.create :users_id => user_id, :privileges_id => CONCERN_SUBMITTER_ID
        end
      end
    end

    #for each analyst privilege id
    for i in BEGIN_ANALYST_PRIV..END_ANALYST_PRIV
      #get every association of the privilege
      roles = Role.where :privileges_id => i
      roles.each do |r|
        user_id = r.users_id
        #if role does not already exist
        #add role for the user        
        if Role.where(:users_id => user_id, :privileges_id => OBSERVATION_ANALYST_ID).empty?
          Role.create :users_id => user_id, :privileges_id => OBSERVATION_ANALYST_ID
        end
        if Role.where(:users_id => user_id, :privileges_id => CONCERN_ANALYST_ID).empty?
          Role.create :users_id => user_id, :privileges_id => CONCERN_ANALYST_ID
        end
      end
    end

  end
end
