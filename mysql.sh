#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld
VALIDATE $? "Enabling mysql"

systemctl start mysqld  
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up root password"

