#!/bin/bash

# creating the sudo access

USERID=$(id -u)

# for user interaction given colour
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#creating logs folder
LOG_FOLDER="/var/log/mysql.logs"
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

dnf module disable nodejs -y
validate $? "disable nodejs"

dnf module enable nodejs:20 -y
validate $? "enable nodejs:20"

dnf install nodejs -y
validate $? "installing nodejs"

id expense
if [ $? -ne 0 ]; then
     useradd expense 
     validate $? "adding expense"
else
    echo -e "user already exists : $Y SKKIPP $N"
fi

mkdir -p /app

rm -rf /app/*

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "downloading the code"

cd /app
validate $? "change the app directory"

unzip /tmp/backend.zip
validate $? "unzip the code"

npm install
validate $? "dependencies installing"

cp /home/ec2-user/SHELL_EXPENSE/backend.service /etc/systemd/system/backend.service
validate $? "moving the data to server"

dnf install mysql -y
validate $? "installing mysql"

mysql -h 172.31.28.73 -u root -pExpenseApp@1 < /app/schema/backend.sql
validate $? "creating schema"

systemctl daemon-reload
validate $? "daemon reload"

systemctl restart backend
validate $? "restarted backend"

systemctl enable backand
validate $? "enable backend"