# Attendance_Report_Production
This are the main files for the Attendance report program.

To use it, simply download the compose and mongo-init.sh files and edit the compose file to your needs.
Here are some key changes you should make:
*  If you want to use https in the webserver, you will need to mount the certficate and the private to key.
*  For sending the report using and SMTP server, you should add your SMTP server, port, recipents, etc.
*  You can change the time and frequency of the report generation based on your need.

