class CreateReminderRoles < ActiveRecord::Migration[5.2]
  def self.up
    create_table :reminder_roles do |t|
      t.column :reminder_id, :integer
      t.column :role_id, :integer
    end
  end

  def self.down
    drop_table :reminder_roles
  end
end
