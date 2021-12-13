namespace :cache_manager do
  require 'find'

  CACHE_THRESHOLD = 256.to_f # in MB


  def directory_size(path)
    size = 0
    Dir.glob(File.join(path, '**', '*')) { |file| size += File.stat(file).blocks * 512 }
    size
  end


  def get_cache_dir
    Rails.env.to_s == "development" ? "test_cache/" : "view_cache/"
  end


  desc 'checks how much memory in MB the file storage cache is currently consuming'
  task :check_cache => :environment do
    begin
      cache_dir = get_cache_dir
      puts "The space used by the cache directory #{cache_dir} on the disk is #{directory_size(cache_dir)/1000000.to_f} MB"
    rescue => e
      puts "Disk Usage check failed due to #{e.inspect}"
    end
  end


  desc 'checks if file storage cache memory footprint has surpassed the CACHE_THRESHOLD and deletes if it is consuming more space'
  task :clear_cache => :environment do
    begin
      @logger = Logger.new("log/cache_operations.log")
      @logger.info '##################################'
      @logger.info '###### START CLEARING CACHE ######'
      @logger.info '##################################'
      @logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

      cache_dir = get_cache_dir
      space_used_on_disk_mb = directory_size(cache_dir)/1000000.to_f

      if space_used_on_disk_mb > CACHE_THRESHOLD
        FileUtils.rm_rf(Dir["#{cache_dir}*"])
        @logger.info "[INFO] #{space_used_on_disk_mb} MB of cache data Cleared From Cache #{cache_dir}."
      else
        @logger.info "[INFO] Cache #{cache_dir} still within space threshold of #{CACHE_THRESHOLD} MB. Currently at #{space_used_on_disk_mb} MB. Cache Not Cleared."
      end

      @logger.info '######################################'
      @logger.info '###### CACHE CLEARANCE COMPLETE ######'
      @logger.info '######################################'
    rescue => e
      @logger.info "#{e.inspect}"
      @logger.info '####################################'
      @logger.info '###### CACHE CLEARANCE FAILED ######'
      @logger.info '####################################'
    end
  end


  desc 'lists files(mostly view files) that are currently in the cache'
  task :list_cache => :environment do
    begin
      cache_dir = get_cache_dir
      Find.find(cache_dir) { |f| puts f if !File.directory?(f) }
    rescue => e
      puts "Cache listing failed due to #{e.inspect}"
    end
  end

end
