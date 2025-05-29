
/**************************************************
 *                                                *
 *     🔷 Pharmaceutical Management System 🔷     *
 *                                                *
 **************************************************/

 
-- ============================================
--          # creating the database #
-- ============================================

 create database Pharama;
 
 
 
-- ============================================
--            # select the database 
-- ============================================
 
use pharama;



-- ============================================
--               # creating tables 
-- ============================================



-- ============================================
--                # Raw_Material 
-- ============================================

CREATE TABLE Raw_Material (
    Raw_Material_ID INT,      
    Name_ VARCHAR(100),
    CONSTRAINT pri_11 PRIMARY KEY (Raw_Material_ID)
);
 
 
 
-- ============================================
--               # Raw_Received 
-- ============================================

CREATE TABLE Raw_Received (
    Raw_Received_ID INT,      
    Raw_Material_ID INT,     
    Quantity INT,
    Received_Date DATE,
    Supplier_id INT,
    CONSTRAINT pri_1 PRIMARY KEY (Received_ID),
    CONSTRAINT for_1 FOREIGN KEY (Raw_Material_ID)
        REFERENCES Raw_Material (Raw_Material_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
); 



-- ============================================
--                # Raw_Test
-- ============================================

CREATE TABLE Raw_Test (
    Raw_Test_ID INT,           
    Raw_Received_ID INT,     
    s_date DATE,
    e_date DATE,
    QA_status VARCHAR(50),
    CONSTRAINT pri_2 PRIMARY KEY (Raw_Test_ID),
    CONSTRAINT for_2 FOREIGN KEY (Raw_Received_ID)
        REFERENCES Raw_Received (Raw_Received_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- ============================================
--               # Raw_Pass_Stock
-- ============================================

CREATE TABLE Raw_Pass_Stock (
    Raw_Material_ID INT,
    quantity INT,
    CONSTRAINT pri_3 PRIMARY KEY (Raw_Material_ID),
    CONSTRAINT for_3 FOREIGN KEY (Raw_Material_ID)
        REFERENCES Raw_Material (Raw_Material_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- ============================================
--               # Raw_Fail_Stock
-- ============================================

CREATE TABLE Raw_Fail_Stock (
    Raw_Material_ID INT,
    quantity INT,
    CONSTRAINT pri_4 PRIMARY KEY (Raw_Material_ID),
    CONSTRAINT for_4 FOREIGN KEY (Raw_Material_ID)
        REFERENCES Raw_Material (Raw_Material_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- ============================================
--                # Medicine
-- ============================================

CREATE TABLE Medicine (
    MD_id INT,
    Name_ VARCHAR(50),
    CONSTRAINT pri_12 PRIMARY KEY (MD_id)
);



-- ============================================
--             # Production_Medicine
-- ============================================

CREATE TABLE Production_Medicine (
    PM_id INT,
    MD_id INT,
    date_ DATE,
    Quantity INT,
    Raw_Material_ID VARCHAR(50),
    quantity_used VARCHAR(50),
    CONSTRAINT pri_5 PRIMARY KEY (PM_id),
    CONSTRAINT for_5 FOREIGN KEY (MD_id)
        REFERENCES Medicine (MD_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- ============================================
--              # Quality_Test
-- ============================================

CREATE TABLE Quality_Test (
    QT_id INT,
    PM_id INT,
    Result VARCHAR(50),
    date_ DATE,
    CONSTRAINT pri_6 PRIMARY KEY (QT_id),
    CONSTRAINT for_6 FOREIGN KEY (PM_id)
        REFERENCES Production_medicine (PM_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- ============================================
--                # Stock_Pass
-- ============================================

CREATE TABLE Stock_Pass (
    MD_id INT,
    quantity INT,
    CONSTRAINT pri_7 PRIMARY KEY (MD_id),
    CONSTRAINT for_7 FOREIGN KEY (MD_id)
        REFERENCES medicine (MD_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- ============================================
--                # Stock_Fail
-- ============================================

CREATE TABLE Stock_Fail (
    MD_id INT,
    quantity INT,
    CONSTRAINT pri_8 PRIMARY KEY (MD_id),
    CONSTRAINT for_8 FOREIGN KEY (MD_id)
        REFERENCES medicine (MD_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- ============================================
--                # Orders
-- ============================================

CREATE TABLE Orders (
    O_id INT,
    MD_id VARCHAR(50),
    quantity VARCHAR(50),
    customer_id VARCHAR(10),
    date_ DATE,
    CONSTRAINT pri_9 PRIMARY KEY (O_id)
);
 
 
 
-- ============================================
--                # Dispatch
-- ============================================

CREATE TABLE Dispatch (
    dispatch_id INT AUTO_INCREMENT,
    o_id INT,
    dispatch_status VARCHAR(50) DEFAULT 'in_progress',
    start_date DATE,
    end_date DATE DEFAULT NULL,
    CONSTRAINT pri10 PRIMARY KEY (dispatch_id),
    CONSTRAINT for_10 FOREIGN KEY (o_id)
        REFERENCES orders (o_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
 
 
 
-- ============================================
--               # Orders_Summary 
-- ============================================

CREATE TABLE Orders_Summary (
    od_id INT AUTO_INCREMENT,
    md_id INT,
    quantity INT,
    CONSTRAINT pri_11 PRIMARY KEY (od_id)
);





-- ============================================
--      # creating the store procedure #
-- ============================================



-- ============================================
--                # Raw_Material 
-- ============================================

-- used for inserting in Raw_Material 

delimiter //
create procedure Raw_Material(in Raw_Material_ID int ,name_ varchar(100))
begin 
insert into Raw_Material values(Raw_Material_ID,name_);
end //
delimiter ;



-- ============================================
--                # Raw_Received 
-- ============================================

-- used for inserting in Raw_Received 

delimiter //
create procedure Raw_Received(Raw_Received_ID int ,Raw_Material_ID int ,Quantity int,Received_Date date ,Supplier_id int )
begin 
insert into Raw_Received values(Raw_Received_ID,Raw_Material_ID,Quantity,Received_Date,Supplier_id );
end //
delimiter ;



-- ============================================
--                # Raw_test 
-- ============================================

-- used for inserting in  Raw_test 

delimiter //
create procedure  Raw_test(Raw_Test_ID int ,Raw_Received_ID int ,s_date date,e_date date ,QA_status varchar(50))
begin
insert into Raw_test  values (Raw_Test_ID,Raw_Received_ID,s_date,e_date,QA_status);
end //
delimiter ;



-- ============================================
--                # Medicine 
-- ============================================

-- used for inserting in  Medicine 

delimiter //
create procedure Medicine( in id int,Name_ varchar(50))
begin
insert into Medicine values (id,Name_);
end //
delimiter ;



-- ============================================
--                # Production_medicine 
-- ============================================

-- used for inserting in  Production_medicine 
-- check the quantity of raw_material used for medicine making  
      -- if quantity is suitable it inserting the values 
      -- else reflect  error

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



-- ============================================
--                # orders 
-- ============================================

-- used for inserting in  Quality_test

delimiter //
create procedure Quality_test(QT_id int ,PM_id int ,Result varchar(50), date_ date)
begin
insert into Quality_test values(QT_id,PM_id,Result,date_ );
end //
delimiter ;



-- ============================================
--                # orders 
-- ============================================

-- used for inserting in  orders
-- check the quantity of medicine from stock 
      -- if quantity is suitable it inserting the values 
      -- else reflect  error

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



-- ============================================
--                # full_status
-- ============================================

-- used for  checking full_status each department 

delimiter \\
create procedure full_status( in date1_ date )
begin
select r.Raw_Received_ID,Raw_Material_ID,quantity,qa_status from Raw_Received r join Raw_Test rt on r.Raw_Received_ID=rt.Raw_Received_ID  where e_date=date1_;
select p.pm_id,md_id,quantity,result from production_medicine p join Quality_test q on p.pm_id=q.pm_id where q.date_=date1_  ;
select MD_id,sum(Quantity) from  Production_medicine where date_= date1_ group by md_id;
select Raw_Material_ID ,sum(quantity) from Raw_Received where Received_Date=date1_ group by Raw_Material_ID;
SELECT md_id, quantity FROM orders WHERE date_ = date1_ ;
select o_id , dispatch_status from dispatch where date_=date1_ and dispatch_status ="delivered" ;
 end \\
 delimiter ;



-- ============================================
--                # orders_summary
-- ============================================

-- used for  checking orders_summary  

 delimiter \\
 create procedure orders_summary()
 begin 
select md_id ,sum(quantity) from orders_summary group by md_id ;
end \\
delimiter ;



-- ============================================
--                # orders_summary
-- ============================================

-- used for updating the dispatch_status dispatch_ 

delimiter //
create procedure dispatch_(in dispatch int)
begin
update dispatch set dispatch_status="completed" , end_date=date(now()) where dispatch_id=dispatch;
end //
delimiter ;

 
 
 
 
 -- ============================================
--      # creating the Trigger #
-- ============================================



-- ============================================
--                # tri_Raw_pass1
-- ============================================

-- used for Automate inserting  Raw_Pass_Stock,Raw_Fail_Stock

delimiter //
create trigger tri_Raw_pass1
after   insert 
on Raw_Material
for each row
begin 
 INSERT INTO Raw_Pass_Stock VALUES (new.Raw_Material_ID,0);
 insert into Raw_Fail_Stock values (new.Raw_Material_ID,0);
end //
delimiter ;



-- ============================================
--                # tri_Raw_pass
-- ============================================

-- used for Automate update values(quantity) in Raw_Pass_Stock after Raw_testing of raw_material 

delimiter //
create trigger tri_Raw_pass
after insert 
on Raw_test
for each row
begin 
declare sample1 int ;
declare sample2 int ;  
	if new.QA_status="PASS" then
		
        select Raw_Material_ID, quantity into sample1 ,sample2 from Raw_Received  WHERE Raw_Received_ID= NEW.Raw_Received_ID;
update  Raw_Pass_Stock set  quantity=quantity+sample2 where Raw_Material_ID = sample1    ;
   
  END IF;
end //
delimiter ;



-- ============================================
--                # tri_raw_fail1
-- ============================================

-- used for Automate update values(quantity) in Raw_Fail_Stock after Raw_testing of raw_meterial  

 delimiter //
 create  trigger tri_raw_fail1
 after insert 
 on Raw_test
 for each row 
 begin 
 declare sample1 int ;
 declare sample2 int ;
	if new.qa_status="FAIL" then 
		select Raw_Material_ID,quantity into sample1,sample2 from Raw_Received where Raw_Received_ID=new.Raw_Received_ID ;
update Raw_Fail_Stock set quantity =quantity+sample2 where Raw_Material_ID =sample1 ;
 end if;
 end //
 delimiter ;



-- ============================================
--                # tri_stock_pass1
-- ============================================

-- used for Automate insert values(id) in stock_fail and stock_pass after inserting in medicine table   

delimiter //
create trigger tri_stock_pass1
after   insert 
on medicine
for each row
begin 
 insert into stock_fail values (new.md_id,0);
 INSERT INTO stock_pass VALUES (new.Md_ID,0);
end //
delimiter ;



-- ============================================
--                # tri_stock_pass
-- ============================================

-- used for Automate update values(quantity) in stock_pass after quality_test of medicine  

delimiter //
create trigger tri_stock_pass
after insert 
on quality_test 
for each row
begin 
declare sample1 int ;
declare sample2 int ;  
	if new.result="PASS" then
		
        select Md_id, quantity into sample1 ,sample2 from production_medicine   WHERE pm_id = NEW.pm_id;
update  stock_pass set  quantity=quantity+sample2 where Md_id = sample1    ;
   
  END IF;
end //
delimiter ;



-- ============================================
--                # tri_raw_fail
-- ============================================

-- used for Automate update values(quantity) in stock_fail after quality_test of medicine  

 delimiter //
 create  trigger tri_raw_fail
 after insert 
 on quality_test
 for each row 
 begin 
 declare sample1 int ;
 declare sample2 int ;
	if new.result="FAIL" then 
		select md_id,quantity into sample1,sample2 from production_medicine where pm_id=new.pm_id ;
update stock_fail set quantity =quantity+sample2 where md_id =sample1 ;
 end if;
 end //
 delimiter ;
 
 
 
 -- ============================================
--                # tri_dispatch
-- ============================================

-- used for Automate inserting in dispatch values after inserting in orders   

 delimiter //
 create trigger tri_dispatch 
 after insert 
 on orders 
 for each row 
 begin
 insert into dispatch(o_id,start_date) values (new.o_id ,date(now()));
 end //
delimiter ;



 -- ============================================
--                # tri_pb
-- ============================================

-- used for Automate update values(quantity) in Raw_Pass_Stock after inserting in production_medicine 

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



 -- ============================================
--                # tri_pb1
-- ============================================

-- used for Automate update values(quantity) in stock_pass after inserting in orders
-- used for Automate inserting in orders_summary values after inserting in orders   

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

 