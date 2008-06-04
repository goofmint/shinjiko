class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
    
    ['*trunk*', 'branch', 'tag'].each { |name|
      Category.create :name => name
    }
  end

  def self.down
    drop_table :categories
  end
end
