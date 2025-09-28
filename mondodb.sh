#!/bin/bash

source ./common.sh



cp mongo.repo /etc/yum.repos.d/mongo.repo  &>>$LOG_FILE
VALIDATE $? "Setting up the Mongod file"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl start mongod  &>>$LOG_FILE
VALIDATE $? "Starting MonogoDB"

sed -i 's/127.0.0.1/ 0.0.0.0/g' /etc/mongod.conf  &>>$LOG_FILE
VALIDATE $? "Allowing the Ports"

systemctl restart mongod  &>>$LOG_FILE
VALIDATE $? "Restarting the MongoDB"