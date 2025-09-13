#!/bin/bash

# creating the sudo access

USERID=$(id -u)

# for user interaction given colour
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating logs folder
LOG_FOLDER="/var/log/backend.logs"
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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
validate $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
validate $? "enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE_NAME
validate $? "installing nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]; then
     useradd expense &>>$LOG_FILE_NAME
     validate $? "adding expense"
else
    echo -e "user already exists : $Y SKKIPP $N"
fi

mkdir -p /app

rm -rf /app/*

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
validate $? "downloading the code"

cd /app
validate $? "change the app directory"

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
validate $? "unzip the code"

npm install &>>$LOG_FILE_NAME
validate $? "dependencies installing"

cp /home/ec2-user/shell_expense/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
validate $? "moving the data to server"

dnf install mysql -y &>>$LOG_FILE_NAME
validate $? "installing mysql"

mysql -h 172.31.28.238 -u root -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
validate $? "creating schema"

systemctl daemon-reload &>>$LOG_FILE_NAME
validate $? "daemon reload"

systemctl restart backend &>>$LOG_FILE_NAME
validate $? "restarted backend"

systemctl enable backand &>>$LOG_FILE_NAME
validate $? "enable backend"