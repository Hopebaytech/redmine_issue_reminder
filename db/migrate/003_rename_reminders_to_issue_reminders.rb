class RenameRemindersToIssueReminders < ActiveRecord::Migration
  def self.up
    rename_table :reminders, :issue_reminders
  end

 def self.down
    rename_table :issue_reminders, :reminders
 end
end