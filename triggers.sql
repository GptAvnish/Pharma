
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


delimiter //
create trigger tri_Raw_pass
after insert 
on Raw_test
for each row
begin 
declare sample1 int ;
declare sample2 int ;  
	if new.QA_status="passed" then
		
        select Raw_Material_ID, quantity into sample1 ,sample2 from Raw_Recieved  WHERE Raw_Recieved_ID= NEW.Raw_Recieved_ID;
update  Raw_Pass_Stock set  quantity=quantity+sample2 where Raw_Material_ID = sample1    ;
   
  END IF;
end //
delimiter ;



 delimiter //
 create  trigger tri_raw_fail1
 after insert 
 on Raw_test
 for each row 
 begin 
 declare sample1 int ;
 declare sample2 int ;
	if new.qa_status="Failed" then 
		select Raw_Material_ID,quantity into sample1,sample2 from Raw_Recieved where Raw_Recieved_ID=new.Raw_Recieved_ID ;
update Raw_Fail_Stock set quantity =quantity+sample2 where Raw_Material_ID =sample1 ;
 end if;
 end //
 delimiter ;

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


delimiter //
create trigger tri_stock_pass
after insert 
on quality_test 
for each row
begin 
declare sample1 int ;
declare sample2 int ;  
	if new.result="passed" then
		
        select Md_id, quantity into sample1 ,sample2 from production_medicine   WHERE pm_id = NEW.pm_id;
update  stock_pass set  quantity=quantity+sample2 where Md_id = sample1    ;
   
  END IF;
end //
delimiter ;



 delimiter //
 create  trigger tri_raw_fail
 after insert 
 on quality_test
 for each row 
 begin 
 declare sample1 int ;
 declare sample2 int ;
	if new.result="Failed" then 
		select md_id,quantity into sample1,sample2 from production_medicine where pm_id=new.pm_id ;
update stock_fail set quantity =quantity+sample2 where md_id =sample1 ;
 end if;
 end //
 delimiter ;

 delimiter //
 create trigger tri_dispatch 
 after insert 
 on orders 
 for each row 
 begin
 insert into dispatch(o_id,start_date) values (new.o_id ,date(now()));
 end //
delimiter ;
 