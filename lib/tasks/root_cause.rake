namespace :root_causes do
  TEST_RUN = false
  task :clone_tree => :environment do
    puts 'Please provide the ID of the Cause Option Root you want to clone:'
    begin
      input = STDIN.gets.strip.to_i
      root = CauseOption.find(input)
    rescue
      puts "ERROR: Could not find Root Cause Option with provided input - Aborted"
    end

    CauseOption.transaction do
      copy = root.clone
      copy.save unless TEST_RUN
      $ind = 0
      puts "#{' '*$ind}New Tree made: #{str(copy)}"
      clone_children(root, copy, true)
    end

  end

  def clone_children(origin, destination, deep=false)
    if origin.children.present?
      $ind += 2
      puts "#{' '*$ind}Cloning Children from #{str(origin)}:"
      $ind += 2
      origin.children.each do |child|
        copy = child.clone
        copy.save unless TEST_RUN
        destination.cause_options << copy unless TEST_RUN
        puts "#{' '*$ind}Child #{str(copy)}"
        clone_children(child, copy, deep) if deep
      end
      $ind -= 4
    end
  end

  def str(node)
    "Node #{node.id}: #{node.name} (#{node.level})"
  end

end
