# Attendance_Report_Production
This are the main files for the Attendance report program.

To use this program, simply follow the following steps:
1. Download the compose, .env and mongo-init.sh files.
2. Have them all in the same directory.
3. Edit the compose file so it suits your needs best. here are some key changes you can make:
  Here are some key changes you should make:
  *  If you want to use https in the webserver, you will need to mount the certficate and the private to key.
  *  For sending the report using and SMTP server, you should add your SMTP server, port, recipents, etc.
  *  You can change the time and frequency of the report generation based on your need.
4. If you want to have captcha enabled, just add you site key and secret to the .env files and have CAPTCHA_ENABLED set to true in the compose file.
5. start the program using docker compose up -d.
6. Once its up, the mongo container will reset the root password. it will be on the container logs, in case you need it.

