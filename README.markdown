Redmine Issue Reminder
==============

Compatible with redmine 2.6.1.stable

Plugin provides an easy to use interface to set up automatic email reminder to every project. 
Every reminder uses a custom query with all their filter options to select issues 
and performs periodical email transmission on a role basis.

Following intervals are possible:
 - Daily (Selecting interval from every 1st day until every 6th day)
 - Weekly (Selecting weekday)
 - Monthly (Selecting day of the month)

## Screenshots

![](http://farm7.static.flickr.com/6109/6294745006_49986ec541_b.jpg)

## Installation - Linux

Download the sources and put them to your vendor/plugins folder.

    $ cd {REDMINE_ROOT}/plugins
    $ git clone https://github.com/Hopebaytech/redmine_issue_reminder.git

Install required gem for plugin

    $ bundle install

Migrate database.

    $ rake db:migrate:plugins

(See also http://www.redmine.org/projects/redmine/wiki/Plugins )    

For the periodical transmission a daily cron job has to be created:
      
    $ sudo crontab -e
    0 6 * * * cd {REDMINE_ROOT} && rake reminder:exec RAILS_ENV="production" > /dev/null 2>&1
    
Restart Redmine

Run Redmine and have a fun!

The reminder functionality can be activated in each project as module and can be configured through the project menu entry "Reminder Settings".
A special right needs to be configured in order to allow project member to edit reminder.

## Installation - Windows

Enviroment : Winxp + Redmine 1.2.X + Mysql 5.X
 
 1. Write a bat file such as these

 ########################################
 
 echo on
 
 cd {REDMINE_ROOT}
 
 rake reminder:exec RAILS_ENV="production"
 
 ########################################
 
 2. config a schedule just follow this
 http://www.iopus.com/guides/winscheduler.htm
 
 3. then start the redmine server.
 
## Testing redminder mail

To send test mail without inverval check:

    rake reminder:exec[test]

## Troubleshouting

### How can i customize the queries?

Take a look at the official documentation about custom queries: 
http://www.redmine.org/projects/redmine/wiki/RedmineIssueList#Custom-queries

### I don't see the Reminder Settings

Add permission to Your user.

### The issue reminder doesn't send mails

We use redmine internal mail send functions, therefore the outgoing email settings 
has to be set in config/emai.yml or config/configuration.yml

### I can not use the windows scheduler (WinXP related)

You need to have a user password set for your windows user in order to use the windows scheduler.

(See also here: http://technet.microsoft.com/en-us/library/cc785125(WS.10).aspx )

## Translations

- de by Michael Kling
- en by Boško Ivanišević
- sr-YU by Boško Ivanišević
- sr by Boško Ivanišević

Thanks for the contribution. 

## To-Do List

- Fix: changing interval type updates interval value @ "New reminder"
- Fix: cancel button @ "Edit"
- Fix: load value per reminder @ "Edit"

## Changelog

### 2014/6/3

 - Inline CSS from site setting, What You See Is What You Get. Require `$ bundle install`

### 2014/5/23

 - Add a way to test by rake command
 - User can use all queries viviable at redmine page to set reminder.
 - Fix async_smtp can't
 - Fix compatibility with Redmine 2.5.1

### 0.0.1

 - initial release
 - matches the basic requirements
