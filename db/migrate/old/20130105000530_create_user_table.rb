class CreateUserTable < ActiveRecord::Migration
  def self.up
   create_table "users", :force => true do |t|
    t.string "username"
    t.string "email"
    t.string "password_hash"
    t.string "password_salt"
    t.string "first_name"
    t.string "last_name"
    t.string "level"
    t.string "full_name"
    t.string "airport"
    t.string "module_access"
   end
  end

  def self.down
    remove_column :users, :username   
    remove_column :users, :email      
    remove_column :users, :password_hash
    remove_column :users, :password_salt   
    remove_column :users, :first_name 
    remove_column :users, :last_name  
    remove_column :users, :level      
    remove_column :users, :full_name  
    remove_column :users, :airport    
    remove_column :users, :module_access
  end
end
