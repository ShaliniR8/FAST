task :link_participations_to_users => :environment do

  file = "/home/devuser/taeho/data_import/wbat_data_import/import/data/participations.csv"
  File.open(file).each_line do |line|

    obj_id = line.strip.split(',')[0]
    poc_id = line.strip.split(',')[1]

    begin
      participation = Participation.where(obj_id: obj_id.to_i).first
    rescue
      p "[FAILED] missing Participation odj_id ##{obj_id}"
    end

    begin
      user = User.where(poc_id: poc_id.to_i).first
    rescue
     p "[FAILED] missing User poc_id ##{poc_id}"
   end

    if participation.present? && user.present?
      p "[info] Update participation #{user.full_name}"
      participation.user = user
      participation.save
    end

  end

end
