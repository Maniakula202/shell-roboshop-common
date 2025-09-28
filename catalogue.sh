#!/bin/bash

source ./common.sh

app_name="catalogue"

check_root
app_setup
nodejs_setup
systemd_setup


cp $PRESENT_DIRECTORY/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copying the monogo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing the monogoDB client package"

INDEX=$(mongosh mongodb.manidevops.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $DOMAIN_NAME </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

restart_setup



