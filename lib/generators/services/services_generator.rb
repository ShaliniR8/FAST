class ServicesGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def init_services
    @airport_code = name
    empty_directory 'services'
  end

  def generate_delayed_job_service
    service = "delayed_job_PST_#{AIRLINE_CODE}.service"
    template 'delayed_job.service.erb', "services/#{service}"
    puts "To register DelayedJob service:"
    puts "  sudo ln -s #{Rails.root}/services/#{service} /etc/systemd/system/#{service}"
    puts "  sudo systemctl daemon-reload"
    puts "  sudo systemctl enable #{service}"
    puts "  sudo systemctl start #{service}"
  end
end
