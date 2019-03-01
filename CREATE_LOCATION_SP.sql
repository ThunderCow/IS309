/*
CREATE_LOCATION_SP.  Add a new location to the VM_LOCATION table.  
This procedure should take as input location-related attributes and create a 
new location entry.  This procedure does not set the latitude/longitude values, 
only address information a user might provide.  If the country, postalcode, and 
street portion of the address match, then a new location is not added. The 
identifier for the location created or found is returned as an output parameter.

PARAMETERS:  Described below
RETURNS:  a new or existing location_id, using the p_location_id output parameter
ERROR MESSAGES:
  Error text:  "Missing mandatory value for parameter (x).  No location added." 
  Error meaning: A mandatory value is missing.  Here, y = 'CREATE_LOCATION_SP'
  Error effect: Because a mandatory value is not provided, no data are 
    inserted into the VM_LOCATION table.  The p_location_id value returned is 
    NULL.
*/
create or replace procedure CREATE_LOCATION_SP (
                          -- an output parameter
  p_location_country	             VM_LOCATION.LOCATION_COUNTRY%TYPE, 
  p_location_postal_code             VM_LOCATION.LOCATION_POSTAL_CODE%TYPE,
  p_location_street1	             VM_LOCATION.LOCATION_STREET_1%TYPE, 
  p_location_street2	             VM_LOCATION.LOCATION_STREET_2%TYPE, 
  p_location_city	                 VM_LOCATION.LOCATION_CITY%TYPE, 
  p_location_administrative_region   VM_LOCATION.LOCATION_ADMINISTRATIVE_REGION%TYPE
)

IS
ex_error exception;
p_count number (10);
err_msg_txt varchar(200) :=null;
lv_lid_p_location_id NUMBER;
p_location_id  NUMBER;
inserted_id number;

BEGIN

select count (*)
into p_count
from VM_LOCATION
WHERE LOCATION_COUNTRY = p_location_country AND LOCATION_POSTAL_CODE = p_location_postal_code AND LOCATION_STREET_1 = p_location_street1;

IF p_count > 0
then
err_msg_txt := 'Location is already existed';
raise ex_error; 

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

end if;

lv_lid_p_location_id := VM_LOCATION_sq.NEXTVAL;

Insert Into VM_LOCATION (
    "LOCATION_ID",
    "LOCATION_COUNTRY",
    "LOCATION_POSTAL_CODE",
    "LOCATION_STREET_1",
    "LOCATION_STREET_2",
    "LOCATION_CITY",
    "LOCATION_ADMINISTRATIVE_REGION")
VALUES (
    lv_lid_p_location_id,
    p_location_country,
    p_location_postal_code,
    p_location_street1,
    p_location_street2,
    p_location_city,
    p_location_administrative_region)
    RETURNING lv_lid_p_location_id INTO inserted_id;
    DBMS_OUTPUT.PUT_LINE('Newly created data, has the PERSON_ID = '||inserted_id);

commit;

p_location_id := lv_lid_p_location_id;

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

BEGIN 
CREATE_LOCATION_SP('norway', '2226', 'Dronningensgate 69', 'Dronningensgate 67', 'Kristiansand', 'Vestagder'); 
COMMIT;
END;
/
