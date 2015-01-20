class ReminderRole < ActiveRecord::Base
  unloadable
  belongs_to :issue_reminder
  belongs_to :role
end
