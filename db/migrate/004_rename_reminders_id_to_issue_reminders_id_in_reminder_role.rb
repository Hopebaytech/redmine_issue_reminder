class RenameRemindersIdToIssueRemindersIdInReminderRole < ActiveRecord::Migration
  def self.up
    rename_column :reminder_roles, :reminder_id, :issue_reminder_id
  end

 def self.down
    rename_column :reminder_roles, :issue_reminder_id, :reminder_id
 end
end