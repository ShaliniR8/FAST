class RemoveVisualizationsFromQueries < ActiveRecord::Migration
  def self.up
    #rename_column :queries, :visualizations, :old_vis
    Query.all.each do |query|
      puts "here"
      (query.old_vis || []).each do |vis|
        QueryVisualization.create({
          owner_id: query.id,
          x_axis: vis,
        }) if vis.present?
      end
    end
    #remove_column :queries, :visualizations
  end

  def self.down
    #rename_column :queries, :old_vis, :visualizations
  end
end
