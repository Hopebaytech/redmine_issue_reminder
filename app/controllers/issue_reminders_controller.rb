class IssueRemindersController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :authorize, :only => :index

  def index
    needs_refresh = false
    @reminders = IssueReminder.find_all_by_project_id(@project)
    @reminders.each do |reminder|
      if reminder.query.nil?
        reminder.destroy
        needs_refresh = true
      end
    end
    @reminders = IssueReminder.find_all_by_project_id(@project) if needs_refresh
    
    @reminder = IssueReminder.new
  end

  def create
    reminder = IssueReminder.new(params[:reminder])
    reminder.interval_value = params[:interval_value].to_i
    if reminder.save
      Role.find_all_givable.each do |role|
        if params[role.name.downcase]
          rr = ReminderRole.new
          rr.issue_reminder = reminder
          rr.role = role
          rr.save
        end
      end
      
      flash[:notice] = t :reminder_created
    else
      flash[:error] = t :reminder_not_created
    end
    render(:update) { |page| page.call 'location.reload(true)' }
  end

  def update
    reminder = IssueReminder.find(params[:id])
    if request.put? && reminder.update_attributes(params[:reminder])
      reminder.interval_value = params[:interval_value]
      Role.find_all_givable.each do |role|
        if reminder.roles.include?(role) && params[role.name.downcase].nil?
          reminder.reminder_roles.find_by_role_id(role.id).destroy
        elsif params[role.name.downcase] && !reminder.roles.include?(role)
          rr = ReminderRole.new
          rr.issue_reminder = reminder
          rr.role = role
          rr.save
        end
      end
      
      reminder.save
    end
    render(:update) { |page| page.call 'location.reload' }
  end

  def destroy
    reminder = IssueReminder.find(params[:id])
    if reminder
      reminder.destroy
    end
    render(:update) {|page| page.call 'location.reload'}
  end

  def update_interval_values
    vals = IssueReminder.interval_values_for(params[:interval])
    begin
      reminder = IssueReminder.find(params[:issue_reminder_id])
    rescue ActiveRecord::RecordNotFound
      reminder = IssueReminder.new
    end
    
    render :update do |page|
      page.replace_html "interval_values-#{params[:reminder_id]}",
      :partial => 'interval_values',
      :locals => { :possible_values => vals, :selected_value => nil, :reminder => reminder}
    end
  end

  private

  def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      @project = Project.find(params[:reminder][:project_id]) if params[:reminder]
    end
  end
end
