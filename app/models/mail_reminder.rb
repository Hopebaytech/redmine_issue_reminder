require "date"

class MailReminder < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  unloadable

  WEEKLY_INTERVAS = Date::DAYNAMES
  MONTHLY_INTERVALS = [1..31]

  has_many :reminder_roles, :dependent => :destroy
  has_many :roles, :through => :reminder_roles
  belongs_to :query
  belongs_to :project

  validates_presence_of :query_id
  
  def self.intervals
    [:daily, :weekly, :monthly]
  end

  def self.daily_intervals
    [:every_day,
     :every_second_day,
     :every_third_day,
     :every_fourth_day,
     :every_fifth_day,
     :every_sixth_day]
  end

  def self.weekly_intervals
    Date::DAYNAMES
  end

  def self.monthly_intervals
    (1..31).to_a
  end

  def self.interval_values_for(interval)
    case interval.to_s.downcase
    when("daily")
      daily_intervals.enum_for(:each_with_index).collect {|val,idx| [interval_value_display("daily", val), idx]}
    when("weekly")
      weekly_intervals.enum_for(:each_with_index).collect {|val,idx| [interval_value_display("weekly", val), idx]}
    when("monthly")
      monthly_intervals.enum_for(:each).collect {|val| [interval_value_display("monthly", val), val]}
    else
      []
    end
  end

  def self.interval_value_display(interval, value)
    case interval
    when("daily")
      value = MailReminder.daily_intervals[value] if value.is_a? Integer
      l(value)
    when("weekly")
      value = Date::DAYNAMES[value] if value.is_a? Integer
      l(:every_weekly_format) % l(value.downcase.to_sym)
    when("monthly")
      l(:every_of_month_format) % value
    else
      "Unknown"
    end
  end

  def last_execute
    result = Time.now
    if executed_at.nil? || (updated_at > executed_at)
      result = updated_at
    else
      result = executed_at
    end
    return result
  end

  def execute?
    case interval
    when "daily"
      execute_daily?
    when "weekly"
      execute_weekly?
    when "monthly"
      execute_monthly?
    else
      false
    end
  end

  def execute_daily?
    return false if last_execute.to_date == DateTime.current.to_date
    
    diff = ((Time.now - last_execute) / 1.day).round.to_i
    return diff >= interval_value + 1
  end

  def execute_weekly?
    return false if last_execute.to_date == DateTime.current.to_date

    return Time.now.wday == interval_value
  end

  def execute_monthly?
    return false if last_execute.to_date == DateTime.current.to_date

    if Time::days_in_month(Time.now.month) < interval_value
      if Time.now.mday == Time.days_in_month(Time.now.month)
        return true
      else
        return false
      end
    else
      return Time.now.mday == interval_value
    end
  end

  attr_accessible :project_id, :query_id, :interval
end
