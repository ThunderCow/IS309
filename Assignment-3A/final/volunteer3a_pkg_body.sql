CREATE OR REPLACE PACKAGE BODY volunteer3a_pkg 
IS
PROCEDURE CREATE_PERSON_PP (
        p_person_id         OUT VM_PERSON.PERSON_ID%TYPE,
        p_person_email      IN  VM_PERSON.PERSON_EMAIL%TYPE,
        P_person_given_name IN  VM_PERSON.PERSON_GIVEN_NAME%TYPE,
        p_person_surname    IN  VM_PERSON.PERSON_SURNAME%TYPE,
        p_person_phone      IN  VM_PERSON.PERSON_PHONE%TYPE
    )
IS

ex_error EXCEPTION;
err_msg_txt VARCHAR(150) :=NULL;
chk_pr_id NUMBER;
chk_pr_dup NUMBER;
inserted_id NUMBER;
lv_person_id_out NUMBER;
person_id NUMBER;
lv_henter_verdi NUMBER;

cursor chk_ID is
    SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_person_email;

/*CURSOR chk_dup is
    SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_ID = person_id;*/

BEGIN
/*
OPEN chk_dup;
FETCH chk_dup INTO chk_pr_dup;
    IF chk_dup%FOUND THEN
        err_msg_txt := 'THE PERSON_ID IS ALREADY FOUND, THE ID IS: ' || person_id || ' THUS, NOT INSERTING NEW DATA ';
        RAISE ex_error;
    END IF;
    CLOSE chk_dup;*/

/*if person_id is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_ID  can not be null. 
The p_person_id value returned is NULL.  ';
raise ex_error;*/

if p_person_email is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_EMAIL  can not be null. 
The p_person_id value returned is NULL.  ';
raise ex_error;

elsif p_person_given_name is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_GIVEN_NAME  can not be null.
The p_person_id value returned is NULL.  ';
raise ex_error;

elsif p_person_surname is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_SURNAME  can not be null. 
The p_person_id value returned is NULL.  ';
raise ex_error;
end if;

OPEN chk_ID;
FETCH chk_ID INTO chk_pr_id;
    IF chk_ID%FOUND THEN
        err_msg_txt := 'THE EMAIL IS ALREADY EXISTED ' || p_person_email || ' IN CONTEXT TO PERSON ID WHICH IS ' || chk_pr_id ;
        p_person_id := chk_pr_id;
        RAISE ex_error;
    END IF;
    CLOSE chk_ID; 

lv_henter_verdi := PERSON_SQ.NEXTVAL;

INSERT INTO VM_PERSON (
    "PERSON_ID",
    "PERSON_EMAIL",
    "PERSON_GIVEN_NAME",
    "PERSON_SURNAME",
    "PERSON_PHONE")
VALUES (
    lv_henter_verdi,
    p_person_email,
    p_person_given_name,
    p_person_surname,
    p_person_phone)
    RETURNING lv_henter_verdi INTO inserted_id;
    DBMS_OUTPUT.PUT_LINE('Newly created data, has the PERSON_ID = '||inserted_id);
    COMMIT;
    
p_person_id :=  lv_henter_verdi;

Exception
when ex_error then
dbms_output.put_line(err_msg_txt);
rollback;
when others then
dbms_output.put_line(' the error code is: ' || sqlcode);
dbms_output.put_line(' the error msg is: ' || sqlerrm);
rollback;

END CREATE_PERSON_PP;

PROCEDURE CREATE_LOCATION_PP (
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


IF  p_location_country is null then
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

p_location_id := lv_lid_p_location_id;

EXCEPTION
WHEN ex_error THEN
dbms_output.put_line (err_msg_txt);
rollback;
WHEN OTHERS THEN
dbms_output.put_line (' THE ERROR CODE IS' || sqlcode);
dbms_output.put_line (' THE ERROR MSG IS' || sqlerrm);
rollback;

END CREATE_LOCATION_PP;

END volunteer3a_pkg;
/
