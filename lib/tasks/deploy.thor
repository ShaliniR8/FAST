class Deploy < Thor
  require 'erb'
  require 'rails'

  desc 'update', 'Updates the current branch. --release will update master and merge into current branch'
  method_option :release, :type => :boolean, aliases: :r
  method_option :verbose, :type => :boolean, aliases: :v
  def update
    puts '### UPDATING CURRENT BRANCH ###'
    branch = %x(git stash).split(' ').to_a[8][0...-1] # git stash
    puts "BRANCH: #{branch}\n"
    puts '  Stashing local changes' if options[:verbose]

    if options[:release]
      puts '  Checking out master for pull' if options[:verbose]
      %x(git checkout master)
    end

    puts '  Pulling from Remote Repository' if options[:verbose]
    %x(git pull --ff-only) # --ff-only prevents merge conflict

    if options[:release]
      puts "  Checking out #{branch}" if options[:verbose]
      %x(git checkout #{branch}) # checkout release branch
      puts "  Merging in Master and pushing the updated branch" if options[:verbose]
      %x(git merge master) # merge master into it
      %x(git push) # push branch
    end
    %x(git stash pop) # git stash pop

    # Handling Database Migrations
    rake_prefix = options[:release] ? 'bundle exec rake ' : 'rake '
    puts '#### HANDLING MIGRATIONS ####'
    migrations = {}
    puts '  Fetching list of needed migrations using db:migrate:status' if options[:verbose]
    %x(#{rake_prefix}db:migrate:status | grep 'down').each_line{ |line|
      terms = line.strip.split(/\s+/)
      migrations[terms[1]] = terms[2..-1].join(' ')
    }

    migrations.each do |migration|
      puts " ## Migrating #{migration[0]}: #{migration[1]} ##"
      %x(#{rake_prefix}db:migrate:up VERSION=#{migration[0]})
    end
  end

end
