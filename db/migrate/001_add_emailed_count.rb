class AddEmailedCount < ActiveRecord::Migration
  def self.up
    add_column :pages, :emailed_count, :integer, :default => 0
  end

  def self.down
    remove_column :pages, :emailed_count
  end
end
