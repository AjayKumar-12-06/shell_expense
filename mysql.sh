#!/bin/bash

# creating the sudo access

USERID=$(id -u)

# for user interaction given colour
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

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

dnf module install mysql-server -y &>>$LOG_FILE_NAME
validate $? "installing mysql-server"

systemctl enable mysqld &>>$LOG_FILE_NAME
validate $? "enable mysqld"

systemctl start mysqld &>>$LOG_FILE_NAME
validate $? "start the mysqld"

mysql -h 172.31.28.238 -u root -pExpenseApp@1 -e show databases; &>>$LOG_FILE_NAME
if [ $? -ne 0 ]; then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE_NAME
    validate $? "setting the password"
else 
    echo -e "already the set the password: $Y Skkipp $N"
fi

