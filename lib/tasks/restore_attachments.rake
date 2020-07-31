desc "Restore missing report attachments"
task :restore_attachment => :environment do
  require 'fileutils'

  Attachment.order('id DESC').each do |attachment|

    unless File.exists?(Rails.root.join('public', 'uploads', 'attachment', 'name', "#{attachment.id}"))

      # find Submission that has the same file name
      found = Attachment.where('owner_type = ? and name = ?', 'Submission', attachment[:name])[0]
      if found

        unless File.exists?(Rails.root.join('public', 'uploads', 'attachment', 'name', "#{found.id}"))
          p "[info] #{found.id} directory does not exist "
          next
        end

        # create dir named id of the attachment
        Dir.mkdir Rails.root.join('public', 'uploads', 'attachment', 'name', "#{attachment.id}")
        p "Create #{attachment.id} directory (#{attachment.owner_type}, #{attachment.owner_id})."

        # copy the found attachment to the newly created dir
        FileUtils.cp Rails.root.join('public', 'uploads', 'attachment', 'name', "#{found.id}", "#{attachment[:name]}"), Rails.root.join('public', 'uploads', 'attachment', 'name', "#{attachment.id}")
        p "Copy #{attachment[:name]} image file from #{found.id} to #{attachment.id}"
      else
        # check the image file manually
        p "[info*] check if #{attachment[:name]} does not exist (#{attachment.id}, #{attachment.owner_type}, #{attachment.owner_id})"
      end
    end
  end
  p "Done"
end
