require 'net/sftp'
namespace :wbat_upload do
  task :sftp_mitre => :environment do
    #prepare files
    Submission.export_all
    host = "ftp.mitrecaasd.org"
    username = "dkhtb964"
    password = "AiPa7uuC"
    current = Time.now - 1.month
    current = Time.now
    airline = BaseConfig::AIRPORT_INFO[:symbol]
    desc "Uploading Mitre Export"
    @log = Logger.new("log/mitre_#{Rails.env}.log")
    @log.level = Logger::INFO
      #login
    Net::SFTP.start(host, username, :password => password) do |sftp|
      year = current.strftime("%Y")
      month = current.strftime("%b").downcase
      begin
        path = File.join(Rails.root, "mitre", year, month)
        emp_groups = Dir.entries(path).select {|f| !File.directory? f}
        emp_groups.each do |emp_group|
          from_path = File.join(path, emp_group)
          @log.info from_path
          target1 = File.join("/#{username}", airline)
          target2 = File.join("/#{username}", airline, year)
          target3 = File.join("/#{username}", airline, year, month)
          target = File.join("/#{username}", airline, year, month, emp_group)
          make_dir(sftp, target1)
          make_dir(sftp, target2)
          make_dir(sftp, target3)
          make_dir(sftp, target)
          @log.info "Upload to #{target}"
          @log.info "Upload from #{from_path}"
          Dir.foreach(from_path) do |f|
            @log.info "Checking #{f}"
            if f.include? "xml"
              sftp.upload!("#{from_path}/#{f}", target+"/"+f)
            end
          end
          @log.info "Upload successful."
        end
      rescue StandardError => bang
        @log.info "Upload Failed."
        @log.info "Error running script: " + bang.message
      end
    end
  end
end



def make_dir(sftp, dir_name)
  begin
    sftp.mkdir! dir_name
  rescue Net::SFTP::StatusException => e
    if e.code == 4
      # directory already exists. Carry on..
    else
      raise
    end
  end
end
