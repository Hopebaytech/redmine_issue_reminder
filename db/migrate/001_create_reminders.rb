class CreateReminders < ActiveRecord::Migration[5.2]
  def self.up
    create_table :reminders do |t|
      t.column :project_id, :integer
      t.column :query_id, :integer
      t.column :interval, :string, :limit => 30
      t.column :interval_value, :integer
      t.column :executed_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end
