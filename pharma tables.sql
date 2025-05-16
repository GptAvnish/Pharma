 ## creating the database 
create database Pharama;
## select the databasse 
use pharama;
## creating tables 
create table Raw_Material(Raw_Material_ID int ,Name_ varchar(100),constraint pri_11 primary key (Raw_Material_ID));
 
create table Raw_Recieved(Raw_Recieved_ID int ,Raw_Material_ID int ,Quantity int,Received_Date date ,Supplier_id int,
constraint pri_1 primary key (Raw_Recieved_ID), constraint for_1 foreign key (Raw_Material_ID) references Raw_Material(Raw_Material_ID) on update cascade on delete cascade) ; ## 1

create table Raw_Test(Raw_Test_ID int ,Raw_Recieved_ID int ,s_date date ,e_date date  ,QA_status varchar(50),
constraint pri_2 primary key (Raw_Test_ID), constraint for_2 foreign key (Raw_Recieved_ID) references Raw_Recieved(Raw_Recieved_ID) on update cascade on delete cascade ); ## 2
  
create table Raw_Pass_Stock(Raw_Material_ID int , quantity int,
constraint pri_3 primary key (Raw_Material_ID), constraint for_3 foreign key (Raw_Material_ID) references Raw_Material(Raw_Material_ID) on update cascade on delete cascade );## 3

create table Raw_Fail_Stock(Raw_Material_ID int , quantity int,
constraint pri_4 primary key (Raw_Material_ID), constraint for_4 foreign key (Raw_Material_ID) references Raw_Material(Raw_Material_ID) on update cascade on delete cascade  );
## done
create table Medicine(MD_id int ,Name_ varchar(50),constraint pri_12 primary key (MD_id));

create table Production_Medicine(PM_id int ,MD_id int,date_ date , Quantity int ,Raw_Material_ID varchar(50),quantity_used varchar(50),
constraint pri_5 primary key(PM_id), constraint for_5 foreign key (MD_id) references Medicine(MD_id) on update cascade on delete cascade); ## 4

create table Quality_Test(QT_id int ,PM_id int ,Result varchar(50), date_ date,
constraint pri_6 primary key(QT_id), constraint for_6 foreign key (PM_id) references Production_medicine(PM_id) on update cascade on delete cascade) ; ## 5

create table Stock_Pass(MD_id int , quantity int ,
constraint pri_7 primary key(MD_id ), constraint for_7 foreign key (MD_id) references medicine(MD_id) on update cascade on delete cascade); ##6

create table Stock_Fail(MD_id int , quantity int,
constraint pri_8 primary key(MD_id ), constraint for_8 foreign key (MD_id) references medicine(MD_id) on update cascade on delete cascade);

 create table Orders(O_id int , MD_id varchar(50) ,quantity varchar(50) ,customer_id varchar(10),date_ date ,
 constraint pri_9 primary key(O_id));
 
 create table Dispatch (dispatch_id int auto_increment , o_id int ,dispatch_status varchar(50) default "in_progress", start_date date ,end_date date default null,
 constraint pri10 primary key(dispatch_id),constraint for_10 foreign key(o_id) references orders(o_id)on update cascade on delete cascade ) ; 
 
 create table Orders_Summary (od_id int auto_increment , md_id int ,quantity int ,constraint pri_11 primary key(od_id));