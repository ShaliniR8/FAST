namespace :misc_tasks do

require "fileutils"

  desc 'Upload SRA historical attachment - FFT'
  task :upload_attachments => :environment do

    # rename files to match SRA ID
    path = "#{Dir.pwd}/public/uploads/fft_sra_attachments"
    no_match = 0

    Attachment.skip_callback(:create, :after, :create_transaction)

    Dir.open(path).each do |p|

      if p != "." && p != ".."
        filename = File.basename(p, File.extname(p))

        sra_number = filename.split('_')[0]

        # find matching SRA
        matching_sras = Sra.where("title like ?", "%#{sra_number}%")
        if matching_sras.length == 0
          no_match += 1
          puts "NO MATCHING FOUND FOR: #{p}"
        end

        matching_sras.each do |sra|

          options = {
            owner_type: 'Sra',
            owner_id: sra.id,
            name: File.open("#{path}/#{p}")
          }

          attachment = Attachment.new(options)
          attachment.save!

          new_path = "#{Dir.pwd}/public/uploads/attachment/name/#{attachment.id}/"

          FileUtils.mkdir_p(new_path)
          FileUtils.cp("#{path}/#{p}", "#{new_path}")
        end
      end
    end
    Attachment.set_callback(:create, :after, :create_transaction)
    puts "total no match: #{no_match}"
  end

end
