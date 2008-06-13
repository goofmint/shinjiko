class AddUserAndPassword < ActiveRecord::Migration
  def self.up
    add_column :repositories, :username, :string
    add_column :repositories, :password, :string
    add_column :patchsets, :username, :string
    add_column :patchsets, :password, :string
  end

  def self.down
    remove_column :repositories, :username
    remove_column :repositories, :password
    remove_column :patchsets, :username
    remove_column :patchsets, :password
  end
end
