#!/bin/bash

echo "Enter Host Name for MySQL"
read mysql_host_name
echo "Enter Database Name for MySQL"
read mysql_db_name
echo "Enter User Name for MySQL and MongoDB access"
read mysql_username
echo "Enter Password"
read -s mysql_pswd


echo "************* Simple Queries Test Started ****************"

echo "Query single table or collection"

# simple query perf test on employees table data
START_TIME=$SECONDS

mysql -h "$mysql_host_name" -u "$mysql_username" --password="$mysql_pswd" -D "$mysql_db_name" -e \
"SELECT * FROM employees;" > tmp_records_mysql.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by MySQL"
echo $ELAPSED_TIME

# simple query perf test on employees collection data
START_TIME=$SECONDS

mongo --host "$mysql_host_name" "$mysql_db_name" --eval \
'db.employees.find().toArray()' > tmp_records_mongo.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by mongoDB"
echo $ELAPSED_TIME

echo "------------------------------------------------------------------------------------"

echo "Query with single table with 1 filter"

# simple query perf test on employees table data
START_TIME=$SECONDS

mysql -h "$mysql_host_name" -u "$mysql_username" --password="$mysql_pswd" -D "$mysql_db_name" -e \
"SELECT * FROM employees where gender = 'M';" > tmp_records_mysql.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by MySQL"
echo $ELAPSED_TIME

START_TIME=$SECONDS

mongo --host "$mysql_host_name" "$mysql_db_name" --eval \
'db.employees.find({ gender : "M" }).toArray()' > tmp_records_mongo.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by mongoDB"
echo $ELAPSED_TIME



echo "************* Simple Queries Test End ****************"

echo "------------------------------------------------------------------------------------"
echo "************* Complex Queries Test Started ****************"


echo "Query with single table with 4 filters"

# simple query perf test on employees table data
START_TIME=$SECONDS

mysql -h "$mysql_host_name" -u "$mysql_username" --password="$mysql_pswd" -D "$mysql_db_name" -e \
"SELECT * FROM employees where gender='M' and emp_no>270336 and first_name like '%c%'and hire_date>'1995-05-13';" > tmp_records_mysql.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by MySQL"
echo $ELAPSED_TIME

START_TIME=$SECONDS

mongo --host "$mysql_host_name" "$mysql_db_name" --eval \
'db.employees.find({ gender : "M",emp_no : { $gt : 270336}, first_name: /c/, hire_date : { $gt : "1995-05-13"} })' > tmp_records_mongo.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by mongoDB"
echo $ELAPSED_TIME

echo "------------------------------------------------------------------------------------"


echo "Time taken by retreival of data from two tables from MySQL with 1 filter of titles having Engineer"

# simple query perf test on employees table data
START_TIME=$SECONDS

mysql -h "$mysql_host_name" -u "$mysql_username" --password="$mysql_pswd" -D "$mysql_db_name" -e "SELECT * FROM employees WHERE emp_no IN (SELECT emp_no FROM $mysql_db_name.titles WHERE title like '%Engineer%') limit 100;" > tmp_records_mysql.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by MySQL"
echo $ELAPSED_TIME

START_TIME=$SECONDS

mongo --host "$mysql_host_name" "$mysql_db_name" --eval \
'db.employees.aggregate([ {$limit : 100}, {$lookup:{from: "titles", pipeline: [{ $match: { title: /.*Engineer.*/ } },{ $project: { _id: 0, date: { emp_no: "$emp_no", title: "$title" } } } ],as: "titles"}}])' > tmp_records_mongo.txt

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Time taken by mongoDB"
echo $ELAPSED_TIME

echo "------------------------------------------------------------------------------------"

echo "************* Complex Queries Test End ****************"


