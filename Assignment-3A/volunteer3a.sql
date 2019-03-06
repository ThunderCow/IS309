create or replace package volunteer3a_pkg
IS
procedure CREATE_LOCATION_PP (
  p_location_id		    OUT	INTEGER,        -- an output parameter
  p_location_country	IN	VARCHAR,        -- must not be NULL
  p_location_postal_code IN	VARCHAR,        -- must not be NULL
  p_location_street1	IN	VARCHAR,
  p_location_street2	IN	VARCHAR,
  p_location_city	    IN	VARCHAR,
  p_location_administrative_region IN VARCHAR
);
procedure CREATE_PERSON_PP (
    p_person_ID             OUT INTEGER,     -- an output parameter
    p_person_email          IN VARCHAR,  -- Must be unique, not null
    P_person_given_name     IN VARCHAR,  -- NOT NULL, if email is unique (new)
    p_person_surname        IN VARCHAR,  -- NOT NULL, if email is unique (new)
    p_person_phone          IN VARCHAR
);
end volunteer3a_pkg;
/
CREATE OR REPLACE PACKAGE BODY volunteer3a_pkg 
IS
procedure CREATE_PERSON_PP (p_person_email      VM_PERSON.PERSON_EMAIL%TYPE,
                             P_person_given_name VM_PERSON.PERSON_GIVEN_NAME%TYPE,
                             p_person_surname    VM_PERSON.PERSON_SURNAME%TYPE,
                             p_person_phone      VM_PERSON.PERSON_PHONE%TYPE
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
    
lv_person_id_out :=  lv_henter_verdi;

Exception
when ex_error then
dbms_output.put_line(err_msg_txt);
rollback;
when others then
dbms_output.put_line(' the error code is: ' || sqlcode);
dbms_output.put_line(' the error msg is: ' || sqlerrm);
rollback;
    
END CREATE_PERSON_PP;

END volunteer3a_pkg;
/
