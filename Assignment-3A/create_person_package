create or replace procedure CREATE_LOCATION_SP (
  p_location_id             OUT     VM_LOCATION.LOCATION_ID%TYPE,                     -- an output parameter
  p_location_country	     IN        VM_LOCATION.LOCATION_COUNTRY%TYPE, 
  p_location_postal_code    IN         VM_LOCATION.LOCATION_POSTAL_CODE%TYPE,
  p_location_street1	    IN         VM_LOCATION.LOCATION_STREET_1%TYPE, 
  p_location_street2	    IN         VM_LOCATION.LOCATION_STREET_2%TYPE, 
  p_location_city	        IN         VM_LOCATION.LOCATION_CITY%TYPE, 
  p_location_administrative_region IN   VM_LOCATION.LOCATION_ADMINISTRATIVE_REGION%TYPE
)

IS
ex_error exception;
err_msg_txt varchar(200) :=null;
lv_lid_p_location_id NUMBER;
p_location_id_out  NUMBER;
inserted_id number;
chk_dp_id NUMBER;

cursor chk_ID is
    SELECT LOCATION_ID FROM VM_LOCATION WHERE LOCATION_COUNTRY = p_location_country AND LOCATION_POSTAL_CODE = p_location_postal_code AND LOCATION_STREET_1 = p_location_street1;

BEGIN


OPEN chk_id;
FETCH chk_id INTO chk_dp_id;
IF chk_id%FOUND THEN
    err_msg_txt := 'Location is already existing with current ID: ' || chk_dp_id;
    p_location_id := chk_dp_id;
    raise ex_error;
end if; 
CLOSE chk_id;


IF p_location_id is null THEN
err_msg_txt:= 'LOCATION ID CANNOT BE null';
raise ex_error;

ELSIF  p_location_country is null then
err_msg_txt := 'Missing mandatory value for parameter, LOCATION_COUNTRY  can not be null. 
The p_location_country value returned is NULL.  ';
raise ex_error;

elsif p_location_postal_code is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_EMAIL  can not be null. 
The p_person_id value returned is NULL.  ';
raise ex_error;
end if; 

lv_lid_p_location_id := VM_LOCATION_sq.NEXTVAL;

Insert Into VM_LOCATION ("LOCATION_ID", "LOCATION_COUNTRY", "LOCATION_POSTAL_CODE", "LOCATION_STREET_1", "LOCATION_STREET_2", "LOCATION_CITY", "LOCATION_ADMINISTRATIVE_REGION")
VALUES (lv_lid_p_location_id, p_location_country, p_location_postal_code, p_location_street1,  p_location_street2, p_location_city, p_location_administrative_region)
Returning lv_lid_p_location_id INTO inserted_id;
DBMS_OUTPUT.PUT_LINE('NEWLY CREATED DATA, HAS THE LOCATION_ID = ' || inserted_id);

commit;

p_location_id_out := lv_lid_p_location_id;

EXCEPTION
WHEN ex_error THEN
dbms_output.put_line (err_msg_txt);
rollback;
WHEN OTHERS THEN
dbms_output.put_line (' THE ERROR CODE IS' || sqlcode);
dbms_output.put_line (' THE ERROR MSG IS' || sqlerrm);
rollback;

END;
/

DECLARE
output_id NUMBER;
BEGIN
CREATE_LOCATION_SP (output_id,'NORWAY','2226','KONGENSGATE','STREET65','KRISTIANSAND','VEST-AGDER');
dbms_output.put_line (output_id);

END;
/
