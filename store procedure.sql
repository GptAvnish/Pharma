delimiter //
create procedure Raw_Material(in Raw_Material_ID int ,name_ varchar(100))
begin 
insert into Raw_Material values(Raw_Material_ID,name_);
end //
delimiter ;

delimiter //
create procedure Raw_Recieved(Raw_Recieved_ID int ,Raw_Material_ID int ,Quantity int,Recieved_Date date ,Supplier_id int )
begin 
insert into Raw_Recieved values(Raw_Recieved_ID,Raw_Material_ID,Quantity,Recieved_Date,Supplier_id );
end //
delimiter ;

delimiter //
create procedure  Raw_test(Raw_Test_ID int ,Raw_Recieved_ID int ,s_date date,e_date date ,QA_status varchar(50))
begin
insert into Raw_test  values (Raw_Test_ID,Raw_Recieved_ID,s_date,e_date,QA_status);
end //
delimiter ;

delimiter //
create procedure Medicine( in id int,Name_ varchar(50))
begin
insert into Medicine values (id,Name_);
end //
delimiter ;

DELIMITER //
CREATE PROCEDURE Production_medicine(PM_id INT,MD_id INT,date_ DATE,Quantity INT,Raw_Material_ID VARCHAR(100),quantity_used VARCHAR(100))
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE len INT;
  DECLARE sample1 INT;
  DECLARE sample2 INT;
  DECLARE check_qty INT default 0;
  DECLARE abort_update BOOLEAN DEFAULT FALSE;
    SET len = LENGTH(Raw_Material_ID) - LENGTH(REPLACE(Raw_Material_ID, ',', '')) + 1;
  WHILE i <= len DO
    SET sample1 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(Raw_Material_ID, ',', i), ',', -1) AS UNSIGNED);
    SET sample2 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(quantity_used, ',', i), ',', -1) AS UNSIGNED);
    SELECT r.quantity INTO check_qty FROM Raw_Pass_Stock r WHERE r.Raw_Material_ID =sample1 ;
    IF check_qty IS NULL OR check_qty < sample2 THEN
      SET abort_update = TRUE;
    END IF;
    SET i = i + 1;
  END WHILE;
  IF abort_update=FALSE THEN 
    INSERT INTO production_medicine (PM_id, MD_ID, date_, Quantity, Raw_Material_ID, quantity_used) VALUES
    (PM_id, MD_ID, date_, Quantity,Raw_Material_ID, quantity_used);
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient raw material. Cannot proceed.';

  END IF;
END //
DELIMITER ;

delimiter //
create trigger tri_pb
after insert 
on production_medicine 
for each row
begin 
declare sample1 int;
declare sample2 int ;
declare i int default 1; 
declare len  int ;
set len = length(new.Raw_Material_ID)-length(replace(new.Raw_Material_ID,",",""))+1;

WHILE i <= len DO
       SET sample1 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(new.Raw_Material_ID, ',', i), ',', -1) AS UNSIGNED);
       SET sample2 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(new.quantity_used, ',', i), ',', -1) AS UNSIGNED);
       UPDATE Raw_Pass_Stock  SET quantity = quantity - sample2 WHERE Raw_Material_ID = sample1;
       SET i = i + 1;
    END WHILE;
end //
delimiter ;
drop trigger tri_pb;
delimiter //
create procedure Quality_test(QT_id int ,PM_id int ,Result varchar(50), date_ date)
begin
insert into Quality_test values(QT_id,PM_id,Result,date_ );
end //
delimiter ;

DELIMITER //
CREATE PROCEDURE orders(o_id INT,MD_id varchar(50),Quantity varchar(50),customer_id VARCHAR(100),date_ DATE)
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE len INT;
  DECLARE sample1 INT;
  DECLARE sample2 INT;
  DECLARE check_qty INT default 0;
  DECLARE abort_update BOOLEAN DEFAULT FALSE;
  SET len = LENGTH(md_id) - LENGTH(REPLACE(md_id, ',', '')) + 1;
  WHILE i <= len DO
    SET sample1 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(md_id, ',', i), ',', -1) AS UNSIGNED);
    SET sample2 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(quantity, ',', i), ',', -1) AS UNSIGNED);
    SELECT r.quantity INTO check_qty FROM stock_pass r WHERE r.md_id = sample1 limit 1;
    IF check_qty IS NULL OR check_qty < sample2 THEN
      SET abort_update = TRUE;
      set check_qty=0;
    END IF;
    set check_qty=0;
    SET i = i + 1;
  END WHILE;
  IF abort_update=True THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient raw material. Cannot proceed.';
  ELSE
    INSERT INTO orders VALUES (o_id,MD_id,Quantity,customer_id,date_);
    
  END IF;
END //
DELIMITER ;
delimiter //
create trigger tri_pb1
after insert 
on orders
for each row
begin 
declare sample1 int;
declare sample2 int ;
declare i int default 1; 
declare len  int ;
set len = length(new.md_id)-length(replace(new.md_id,",",""))+1;

WHILE i <= len DO
       SET sample1 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(new.md_id, ',', i), ',', -1) AS UNSIGNED);
       SET sample2 = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(new.quantity, ',', i), ',', -1) AS UNSIGNED);
       UPDATE stock_pass SET quantity = quantity - sample2 WHERE md_id = sample1;
       insert into orders_summary(md_id,quantity) values (sample1,sample2);
       SET i = i + 1;
    END WHILE;
end //
delimiter ;


   ##  full_status report by date 
delimiter \\
create procedure full_status( in date1_ date )
begin
select r.Raw_Recieved_ID,Raw_Material_ID,quantity,qa_status from Raw_Recieved r join Raw_Test rt on r.Raw_Recieved_ID=rt.Raw_Recieved_ID  where e_date=date1_;
select p.pm_id,md_id,quantity,result from production_medicine p join Quality_test q on p.pm_id=q.pm_id where q.date_=date1_  ;
select MD_id,sum(Quantity) from  Production_medicine where date_= date1_ group by md_id;
select Raw_Material_ID ,sum(quantity) from Raw_Recieved where Recieved_Date=date1_ group by Raw_Material_ID;
SELECT md_id, quantity FROM orders WHERE date_ = date1_ ;
select o_id , dispatch_status from dispatch where date_=date1_ and dispatch_status ="delivered" ;
 end \\
 delimiter ;

 delimiter \\
 create procedure orders_summary()
 begin 
select md_id ,sum(quantity) from orders_summary group by md_id ;
end \\
delimiter ;

delimiter //
create procedure dispatch_(in dispatch int)
begin
update dispatch set dispatch_status="completed" , end_date=date(now()) where dispatch_id=dispatch;
end //
delimiter ;
call dispatch_(1)
 