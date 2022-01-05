class RenameRemindersToIssueReminders < ActiveRecord::Migration[5.2]
  def self.up
    rename_table :reminders, :issue_reminders
  end

 def self.down
    rename_table :issue_reminders, :reminders
 end
end
