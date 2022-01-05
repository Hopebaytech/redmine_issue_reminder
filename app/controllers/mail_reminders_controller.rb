class MailRemindersController < ApplicationController
  unloadable

  before_action :find_project
  before_action :authorize, :only => :index

  def index
    needs_refresh = false
    @reminders = MailReminder.where(project_id: @project)
    @reminders.each do |reminder|
      if reminder.query.nil?
        reminder.destroy
        needs_refresh = true
      end
    end
    @reminders = MailReminder.where(project_id: @project) if needs_refresh
    @reminder = MailReminder.new
  end

  def create
    # parameters = ActionController::Parameters.new(params[:reminder])
    reminder = MailReminder.new(permit_params)
    reminder.interval_value = params[:interval_value].to_i
    if reminder.save
      Role.find_all_givable.each do |role|
        if params[role.name.downcase]
          rr = ReminderRole.new
          rr.mail_reminder = reminder
          rr.role = role
          rr.save
        end
      end
      flash[:notice] = t :reminder_created
    else
      flash[:error] = t :reminder_not_created
    end
    respond_to do |format|
      format.html { redirect_back(fallback_location: mail_reminders_path) }
      format.js   { render :layout => false }
    end
  end

  def update
    reminder = MailReminder.find(params[:id])
    if request.put? && reminder.update_attributes(permit_params)
      reminder.interval_value = params[:interval_value]
      Role.find_all_givable.each do |role|
        if reminder.roles.include?(role) && params[role.name.downcase].nil?
          reminder.reminder_roles.find_by_role_id(role.id).destroy
        elsif params[role.name.downcase] && !reminder.roles.include?(role)
          rr = ReminderRole.new
          rr.mail_reminder = reminder
          rr.role = role
          rr.save
        end
      end
      
      reminder.save
    end
    respond_to do |format|
      format.html { redirect_back(fallback_location: mail_reminders_path) }
      format.js   { render :layout => false }
    end
  end

  def destroy
    reminder = MailReminder.find(params[:id])
    if reminder
      reminder.destroy
    end
    respond_to do |format|
      format.html { redirect_back(fallback_location: mail_reminders_path) }
      format.js   { render :layout => false }
    end
  end

  def update_interval_values
    vals = MailReminder.interval_values_for(params[:interval])
    begin
      reminder = MailReminder.find(params[:mail_reminder_id])
    rescue ActiveRecord::RecordNotFound
      reminder = MailReminder.new
    end
    
    render partial: "interval_values", :locals => { :possible_values => vals, :selected_value => nil, :reminder => reminder} 
  end

  private

  def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      @project = Project.find(params[:reminder][:project_id]) if params[:reminder]
    end
  end

  def permit_params
    params.require(:reminder).permit(:project_id, :query_id, :interval)
  end
end
