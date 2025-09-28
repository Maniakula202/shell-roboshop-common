#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER_ID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "."  -f1 )
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
PRESENT_DIRECTORY=$PWD
MONGODB_HOST=mongodb.manidevops.fun


mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE


check_root(){
    if [ $USER_ID -ne 0 ]; then
        echo "Error:: Please use the root previlege to run this script" | tee -a $LOG_FILE
        exit 1
    fi 
}


VALIDATE(){
    if [ $? -ne 0 ]; then 
        echo -e "$1..... $R FAILED $N"  | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2..... $G SUCCESS $N" | tee -a $LOG_FILE
    fi 
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Intalling Maven"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Cleaning Maven Package"

    mv target/shipping-1.0.jar shipping.jar 
    VALIDATE $? "Moving Maven Package"
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs:20"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs"
    
    npm install  &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing Python3 dependencies"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating root user"
    else
        echo -e "User already existing.... $Y SKIPPING $N" | tee -a $LOG_FILE
    fi

    mkdir -p /app  &>>$LOG_FILE
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
    VALIDATE $? "Download code to the temp file"

    cd /app 
    rm -rf /app/*  &>>$LOG_FILE
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzinpping the code"
}

systemd_setup(){
    cp $PRESENT_DIRECTORY/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "Copying the $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Deamon reloading"

    systemctl enable $app_name  &>>$LOG_FILE
    VALIDATE $? "Enabling the $app_name services"

    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "Startting the $app_name"
}
restart_setup(){
    systemctl restart $app_name &>>$LOG_FILE
    VALIDATE $? "Restartting the $app_name"
}