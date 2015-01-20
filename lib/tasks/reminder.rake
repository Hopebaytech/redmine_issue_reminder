namespace :reminder do
  desc "Executes all reminders that fulfill time conditions."
  task :exec, [:test] => :environment do |task, args|
    require 'set'
    mail_data = Hash.new{|h, k| h[k] = Set.new}
    reminders = IssueReminder.all
    reminders = reminders.select{|rem| rem.execute?} if args.test != "test"
    reminders.
      select{|rem| rem.project.enabled_module_names.include?('issue_reminder') && rem.query.present?}.
      sort{|l,r| l.project_id <=> r.project_id}.
      each do |rem|
        rem.roles.each do |role|
          role.members.
            select {|m| m.project_id == rem.project_id}.
            reject {|m| m.user.nil?}.
            each do |member|
              mail_data[member.user] << [rem.project, rem.query]
              rem.executed_at = Time.now if args.test != "test"
              rem.save
            end
        end
      end

      # Fixed: reminder mails are not sent when delivery_method is :async_smtp (#5058).
      IssueReminderMailer.with_synched_deliveries do
        mail_data.each do |user, queries_data|
          IssueReminderMailer.issues_reminder(user, queries_data).deliver if user.active?
          puts user.mail
        end
      end
  end
end
