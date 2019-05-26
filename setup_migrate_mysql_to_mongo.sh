#!/bin/bash


if [ -e ./test_db ]
then
echo ">>>>>>>>>MySql test_db found <<<<<<<<<<<<"
	cd ./test_db	
else
# downloading the database
echo ">>>>>>>>>Database Downloading Started<<<<<<<<<<<<"
	git clone https://github.com/datacharmer/test_db
	cd ./test_db
echo ">>>>>>>>>Database Downloading Finished<<<<<<<<<<<<"
fi


echo "******************* Please Enter Following Details **************************"
echo "Enter Host Name for MySQL"
read mysql_host_name
echo "Enter Database Name for MySQL"
read mysql_db_name
echo "Enter User Name for MySQL and MongoDB access"
read mysql_username
echo "Enter Password"
read -s mysql_pswd

if [ -e employees.sql ]
then
echo ">>>>>>>>>MySql schema file ./test_db/employees.sql found <<<<<<<<<<<<"

# set up and migrate db to mongodb
# updating the db name in schema file employee.sql
sed -i "/^DROP/ s/employees/$mysql_db_name/g" employees.sql
sed -i "/^CREATE DATABASE/ s/employees/$mysql_db_name/g" employees.sql
sed -i "/^USE/ s/employees/$mysql_db_name/g" employees.sql

START_TIME=$SECONDS

mysql -h "$mysql_host_name" -u "$mysql_username" --password="$mysql_pswd" < employees.sql

echo ">>>>>>>>>MySql Insertion Completed<<<<<<<<<<<<"

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by MySQL complete employees db insertion "
echo $ELAPSED_TIME

declare -i i=0

START_TIME=$SECONDS
#reading the employee schema then retreiving the table names
mysql -h "$mysql_host_name" -u "$mysql_username" --password="$mysql_pswd" -e \
"SELECT table_name FROM information_schema.tables WHERE table_type='BASE TABLE' and table_schema ='$mysql_db_name';" | while read -r line ; 
do

if [ "$i" -eq 0 ]; then
   echo "tables to collection mapping in progress"
else

echo ">>>>>>>>>>>>Creating collection and inserting for table ('$line')<<<<<<<<<<<<"

#for each table retrieving the data from mysql database
mysql -h "$mysql_host_name" -u "$mysql_username" --password="$mysql_pswd" -D "$mysql_db_name" -e \
	 "SELECT * FROM $line;" > tmp_records.csv

#for each table retrieving the data from mysql database
sed -i 's/\t/,/g' tmp_records.csv

#for each table pushing the data to mongo database
mongoimport --host="$mysql_host_name" -d "$mysql_db_name" -c \
	"$line" --type csv --file tmp_records.csv --headerline

echo ">>>>>>>>>Completed collection and inserting for table ('$line')<<<<<<<<<<<<"

fi

i=$((i+1)) 

done

echo "+++Cleaning Temp files+++"
rm tmp_records.csv

echo ">>>>>>>>>MySql to MongoDB Migration Completed<<<<<<<<<<<<"
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by MongoDB complete employees db insertion "
echo $ELAPSED_TIME


else
    echo "Error: File Not Found - Schema file ./test_db/employees.sql is not found in current directory"
fi
