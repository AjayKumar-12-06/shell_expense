#!/bin/bash

# creating the sudo access

USERID=$(id -u)

# for user interaction given colour
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating logs folder
LOG_FOLDER="/var/log/frontend.logs"
mkdir -p $LOG_FOLDER
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e " $R you must have the sudo access to execute this $N"
        exit 1
    fi
}

check_root

validate() {
    if [ $1 -ne 0 ]; then
        echo -e " $2 $R installing failed $N"
    else
        echo -e " $2 $G installing success $N"
    fi
}

dnf install nginx -y
validate $? "installing nginx"

systemctl enable nginx 
validate $? "enabling nginx"

systemctl start nginx
validate $? "start the nginx"

rm -r /usr/share/nginx/html/*
validate $? "deleting the existing code"


curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
validate $? "dowlinding thw code"

cd /usr/share/nginx/html
validate $? "change the directory"

unzip /tmp/frontend.zip
validate $? "unzip the code"

cp /home/ec2-user/shell_expense/expense.conf /etc/nginx/default.d/expense.conf
validate $? "copying the directory"

systemctl restart nginx
validate $? "reastarting the nginx"

