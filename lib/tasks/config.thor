class Config < Thor
  require 'erb'

  desc 'init |__AIRLINE_CODE__|', 'Not yet implemented'
  def init(airline_code)
    # TODO
  end

  desc 'set_airline |__AIRLINE_CODE__|', 'Sets the airline_code.yml and database.yml files'
  def set_airline(airline_code)
    puts '##########################'
    puts '|| SETTING AIRLINE CODE ||'
    puts '##########################'
    puts "\nAIRLINE CODE: #{airline_code}\n\n"

    @airline_code = airline_code
    set_airline_code
    set_enabled_systems_and_environments
    set_database_yml
  end

  def set_airline_code
    puts "Setting airline_code.yml with value '#{@airline_code}'..."
    Dir.glob("**/airline_code.yml.erb").each do |path|
      transpile_erb path, binding
    end
    puts "\t...done."
  end

  def set_database_yml
    puts "Configuring database.yml for '#{@airline_code}'..."
    Dir.glob("**/database.yml.erb").each do |path|
      transpile_erb path, binding
    end
    puts "\t...done."
  end

  #Reads provided file, uses the binding (defined variables) to interpret the file,
  #Then write it all to a file with identical name minus the '.erb'
  def transpile_erb(filename, bindings)
    File.open(filename, 'r') do |template|
      erb = ERB.new(template.read)
      new_filename = filename.gsub(/\.erb/, '')
      File.open(new_filename, 'w') do |f|
        f.write erb.result(bindings)
      end
    end
  end

  #Defines ENABLED_SYSTEMS and SYSTEM_ENVIRONMENTS from the airline config for use in the thor task
  def set_enabled_systems_and_environments
    config = File.join('app', 'models', 'systems', "#{underscore(@airline_code)}_config.rb")

    if File.exists?(config)
      File.open(config, 'r') do |f|
        f.each_line do |line|
          if line =~ /(ENABLED\_SYSTEMS\s*=.*$)/
            eval $1
            break
          end
        end
      end
      File.open(config, 'r') do |f|
        f.each_line do |line|
          if line =~ /(SYSTEM\_ENVIRONMENTS\s*=.*$)/
            eval $1
            break
          end
        end
      end

      unless defined? ENABLED_SYSTEMS
        throw "ERROR: ENABLED_SYSTEMS is not defined in `#{config}`"
      end
      unless defined? SYSTEM_ENVIRONMENTS
        throw "ERROR: SYSTEM_ENVIRONMENTS is not defined in `#{config}`"
      end
    else
      throw "ERROR: File `#{config}` was not found"
    end
  end


  def underscore(camel_cased_word)
    return camel_cased_word unless /[A-Z-]|::/ =~ camel_cased_word
    word = camel_cased_word.to_s.gsub('::', '/')
    word.gsub!(/\s/, '_')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!('-', '_')
    word.downcase!
    word
  end


end
