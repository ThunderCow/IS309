CREATE OR REPLACE PACKAGE BODY volunteer3a_pkg 
IS

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

BEGIN

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

PROCEDURE CREATE_MEMBER_PP(
  person_id OUT NUMBER,
  mem_Password IN VARCHAR,
  person_Email IN VARCHAR,
  person_Given_Name IN VARCHAR,
  person_Surname IN VARCHAR,
  person_Phone IN VARCHAR,
  location_country	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
  location_postal_code      IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
  location_street1	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
  location_street2	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
  location_city	            IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
  location_administrative_region IN VARCHAR  -- passed to CREATE_LOCATION_SP
)
IS
  person_Id_Out NUMBER;
  out_Location_Id NUMBER;
  lv_return_value number;
  err_msg_txt varchar(150) := '';
  NO_UID_RECIEVED EXCEPTION;
  NO_LID_RECIEVED EXCEPTION;
  NO_PARAMETER_VALUE EXCEPTION;

BEGIN

  if mem_Password is null then
err_msg_txt := 'Missing mandatory value for parameter, mem_password  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif person_Email is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_EMAIL  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif person_Given_Name is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_GIVEN_NAME  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif person_Surname is null then
err_msg_txt := 'Missing mandatory value for parameter, PERSON_SURNAME  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif location_country is null then
err_msg_txt := 'Missing mandatory value for parameter, location_country  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif location_administrative_region is null then
err_msg_txt := 'Missing mandatory value for parameter, location_admin_region  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif location_city is null then
err_msg_txt := 'Missing mandatory value for parameter, location_city  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif location_street1 is null then
err_msg_txt := 'Missing mandatory value for parameter, location_street1  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;

elsif location_postal_code is null then
err_msg_txt := 'Missing mandatory value for parameter, location_postal_code  can not be null.
The mem_id value returned is NULL.  ';
raise NO_PARAMETER_VALUE;
end if;


  CREATE_PERSON_SP(person_Id_Out,person_Email,person_Given_Name,person_Surname,person_Phone);
  IF person_Id_Out IS NULL THEN
    RAISE NO_UID_RECIEVED;
  END IF;
  CREATE_LOCATION_SP(out_Location_Id, location_postal_code, location_street1,location_street2,location_city,location_administrative_region);
  IF out_Location_Id IS NULL THEN
    RAISE NO_LID_RECIEVED;
  END IF;

  dbms_output.put_line(person_Id_Out);
  dbms_output.put_line(out_Location_Id);
  INSERT INTO VM_MEMBER(PERSON_ID, MEMBER_PASSWORD, LOCATION_ID) VALUES (person_Id_Out,mem_Password,out_Location_Id);

  person_id := person_Id_Out;
  COMMIT;

EXCEPTION
  WHEN NO_UID_RECIEVED THEN
    dbms_output.put_line('Invalid value for user id in context of CREATE_MEMBER_SP');
      person_id := NULL;
    ROLLBACK;
  WHEN NO_LID_RECIEVED THEN
    dbms_output.put_line('Invalid value for location id in context of CREATE_MEMBER_SP');
      person_id := NULL;
    ROLLBACK;
  WHEN NO_PARAMETER_VALUE THEN
    dbms_output.put_line(err_msg_txt);
    person_id := NULL;
  ROLLBACK;

END CREATE_MEMBER_PP;

PROCEDURE CREATE_ORGANIZATION_PP (
    p_org_name                  VM_ORGANIZATION.ORGANIZATION_NAME%TYPE,
    p_org_mission               VM_ORGANIZATION.ORGANIZATION_MISSION_STATEMENT%TYPE,
    p_org_descrip               VM_ORGANIZATION.ORGANIZATION_DESCRIPTION%TYPE,
    p_org_phone                 VM_ORGANIZATION.ORGANIZATION_PHONE%TYPE,
    p_org_type                  VM_ORGANIZATION.ORGANIZATION_TYPE%TYPE,
    p_org_creation_date         VM_ORGANIZATION.ORGANIZATION_CREATION_DATE%TYPE,
    p_org_URL                   VM_ORGANIZATION.ORGANIZATION_URL%TYPE,
    p_org_image_URL             VM_ORGANIZATION.ORGANIZATION_IMAGE_URL%TYPE,
    p_org_linkedin_URL          VM_ORGANIZATION.ORGANIZATION_LINKEDIN_URL%TYPE,
    p_org_facebook_URL          VM_ORGANIZATION.ORGANIZATION_FACEBOOK_URL%TYPE,
    p_org_twitter_URL           VM_ORGANIZATION.ORGANIZATION_TWITTER_URL%TYPE,
    p_location_country	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city	            IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_administrative_region IN VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_person_email              IN VARCHAR,  -- passed to CREATE_PERSON_SP
    P_person_given_name         IN VARCHAR,  -- passed to CREATE_PERSON_SP
    p_person_surname            IN VARCHAR,  -- passed to CREATE_PERSON_SP
    p_person_phone              IN VARCHAR   -- passed to CREATE_PERSON_SP
    )
IS

lv_person_id_out Number;
lv_location_id_out NUMBER;
lv_organization_id_out NUMBER;
org_id NUMBER;
ex_error exception;
err_msg_txt varchar(200) :=null;
lv_henter_verdi NUMBER;
inserted_id number;

CURSOR chk_org IS
    SELECT ORGANIZATION_ID FROM VM_ORGANIZATION WHERE VM_ORGANIZATION.ORGANIZATION_NAME = p_org_name;

BEGIN
/*CHECK MANDATROY VALUES AND THROUGH EXCEPTIONS IF ANY VALUE IS MISSING*/
if p_org_name is null then
err_msg_txt := 'Missing mandatory value for parameter, ORGANIZATION_NAME can not be null. 
The p_org_name value returned is NULL.';
raise ex_error;

elsif p_org_mission is null then
err_msg_txt := 'Missing mandatory value for parameter, ORGANIZATION_MISSION_STATEMENT can not be null. 
The p_org_mission value returned is NULL.';
raise ex_error;

elsif p_org_descrip is null then
err_msg_txt := 'Missing mandatory value for parameter, ORGANIZATION_DESCRIPTION can not be null. 
The p_org_descrip value returned is NULL.';
raise ex_error;

elsif p_org_phone is null then
err_msg_txt := 'Missing mandatory value for parameter, ORGANIZATION_PHONE can not be null. 
The p_org_phone value returned is NULL.';
raise ex_error;

elsif p_org_creation_date is null then
err_msg_txt := 'Missing mandatory value for parameter, ORGANIZATION_CREATION_DATE can not be null. 
The p_org_creation_date value returned is NULL.';
raise ex_error;
end if;

/*CREATING PERSON THROUGH CALLING PERSON PROCEDURE*/
SELECT count (*)
INTO lv_person_id_out 
FROM VM_PERSON 
where lv_person_id_out = PERSON_ID;

CREATE_PERSON_SP(
lv_person_id_out, 
p_person_email, 
P_person_given_name, 
p_person_surname, 
p_person_phone);

    IF lv_person_id_out IS NULL THEN
        err_msg_txt := 'Invalild value for parameter ' || lv_person_id_out ||', in context with CREATE_ORGANIZATION_SP';
        RAISE ex_error;
    END IF;
    
/*CREATING LOCATION THROUGH CALLING LOCATION PROCEDURE*/
SELECT count (*)
INTO lv_location_id_out 
FROM VM_LOCATION
WHERE lv_location_id_out = LOCATION_ID;

create_location_sp(
p_location_country,
p_location_postal_code,
p_location_street1,
p_location_street2,
p_location_city,
p_location_administrative_region);

    IF lv_location_id_out IS NULL THEN
        err_msg_txt := 'Invalild value for parameter ' || lv_location_id_out ||', in context with CREATE_ORGANIZATION_SP';
        RAISE ex_error;
    END IF;
    
/*OPENING CURSOR TO FETCH VALUE AND CHECK CONDITION*/
OPEN chk_org;
  FETCH chk_org INTO org_id;
IF chk_org%FOUND THEN
    err_msg_txt := 'Invalid value for parameter ' || lv_organization_id_out || 'In context with ' || org_id || ' Thus, No organization added.';
    dbms_output.put_line('Organization already found');
    RAISE ex_error;
  ELSIF chk_org%NOTFOUND THEN
  dbms_output.put_line('Organization is not found, creating a new in DBMS.');
    END IF;
CLOSE chk_org;


lv_henter_verdi := ORGANIZATION_SQ.NEXTVAL;

/*INSERTING VALUES INTO ORGANIZATION*/
    INSERT INTO VM_ORGANIZATION (
    ORGANIZATION_ID,
    ORGANIZATION_NAME,
    ORGANIZATION_MISSION_STATEMENT,
    ORGANIZATION_DESCRIPTION,
    ORGANIZATION_PHONE,
    ORGANIZATION_TYPE,
    ORGANIZATION_CREATION_DATE,
    ORGANIZATION_URL,
    ORGANIZATION_IMAGE_URL,
    ORGANIZATION_LINKEDIN_URL,
    ORGANIZATION_FACEBOOK_URL,
    ORGANIZATION_TWITTER_URL,
    PERSON_ID,
    LOCATION_ID)

    VALUES (
    lv_henter_verdi,
    p_org_name,
    p_org_mission,
    p_org_descrip,
    p_org_phone,
    p_org_type,
    p_org_creation_date,
    p_org_URL,
    p_org_image_URL,
    p_org_linkedin_URL,
    p_org_facebook_URL,
    p_org_twitter_URL,
    lv_person_id_out,
    lv_location_id_out)
    RETURNING lv_henter_verdi INTO inserted_id;
    DBMS_OUTPUT.PUT_LINE('Newly created data, has the ORAGNIZATION_ID = '||inserted_id);
    COMMIT;

lv_organization_id_out :=  lv_henter_verdi;

/*EXCEPTION SECTION*/
Exception
when ex_error then
dbms_output.put_line(err_msg_txt);
rollback;
when others then
dbms_output.put_line(' the error code is: ' || sqlcode);
dbms_output.put_line(' the error msg is: ' || sqlerrm);
rollback;

END CREATE_ORGANIZATION_PP;

PROCEDURE CREATE_OPPORTUNITY_PP (
    p_opp_id                    OUT INTEGER,        -- output parameter
    p_org_id                    IN  INTEGER,        -- NOT NULL
    p_opp_title                 IN  VARCHAR,   -- NOT NULL
    p_opp_description           IN  LONG,       
    p_opp_create_date           IN  DATE,       -- If NULL, use SYSDATE
    p_opp_max_volunteers        IN  INTEGER,    -- If provided, must be > 0
    p_opp_min_volunteer_age     IN  INTEGER,    -- If provided, must be between 0 and 125
    p_opp_start_date            IN  DATE,
    p_opp_start_time            IN  CHAR,       
    p_opp_end_date              IN  DATE,
    p_opp_end_time              IN  CHAR,
    p_opp_status                IN  VARCHAR,    -- If provided, must conform to domain
    p_opp_great_for             IN  VARCHAR,    -- If provided, must conform to domain
    p_location_country	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city	            IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_administrative_region IN VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_person_email              IN VARCHAR,   -- passed to CREATE_PERSON_SP
    P_person_given_name         IN VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_surname            IN VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_phone              IN VARCHAR    -- passed to CREATE_PERSON_SP    
)
IS

CURSOR chk_dup is
    SELECT OPPORTUNITY_ID FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = p_opp_id;

CURSOR chk_org_id IS
    SELECT ORGANIZATION_ID FROM VM_ORGANIZATION WHERE ORGANIZATION_ID = p_org_id;

lv_person_id_out Number;
lv_location_id_out NUMBER;
lv_p_opp_id_out NUMBER;
chk_pr_dup NUMBER;
lv_chk_id NUMBER;
inserted_id number;

ex_error exception;
err_msg_txt varchar(200) :=null;
--lv_henter_verdi NUMBER;
BEGIN

OPEN chk_dup;
FETCH chk_dup INTO chk_pr_dup;
    IF chk_dup%FOUND THEN
        err_msg_txt := 'THE OPPORTUNITY_ID IS ALREADY FOUND, THE ID IS: ' || p_opp_id || ' THUS, NOT INSERTING NEW DATA ';
        RAISE ex_error;
    END IF;
    CLOSE chk_dup;

/*Check Mandatory values for Create_Opportunity*/
if p_opp_id is null then
err_msg_txt := 'Missing mandatory value for parameter, OPPORTUNITY_ID  can not be null. 
The p_opp_id value returned is NULL.  ';
raise ex_error;

elsif p_opp_title is null then
err_msg_txt := 'Missing mandatory value for parameter, OPPORTUNITY_TITLE  can not be null. 
The p_opp_title value returned is NULL.  ';
raise ex_error;

elsif p_opp_description is null then
err_msg_txt := 'Missing mandatory value for parameter, OPPORTUNITY_DESCRIPTION  can not be null.
The p_opp_description value returned is NULL.  ';
raise ex_error;

elsif p_opp_create_date is null then
err_msg_txt := 'Missing mandatory value for parameter, OPPORTUNITY_CREATE_DATE  can not be null. 
The p_opp_create_date value returned is NULL.  ';
raise ex_error;
end if;

/*CREATING PERSON THROUGH CALLING PERSON PROCEDURE*/
    SELECT count (*)INTO lv_person_id_out FROM VM_PERSON where lv_person_id_out = PERSON_ID;

CREATE_PERSON_SP(
    lv_person_id_out,
    p_person_email,
    P_person_given_name,
    p_person_surname,
    p_person_phone);
    
    IF lv_person_id_out IS NULL THEN
        err_msg_txt := 'Invalild value for parameter ' || lv_person_id_out ||', in context with CREATE_ORGANIZATION_SP';
        RAISE ex_error;
    END IF;
    
/*CREATING LOCATION THROUGH CALLING LOCATION PROCEDURE*/
SELECT count (*) 
INTO lv_location_id_out 
FROM VM_LOCATION 
WHERE lv_location_id_out = LOCATION_ID;

create_location_sp(
    lv_location_id_out,
    p_location_country,
    p_location_postal_code,
    p_location_street1,
    p_location_street2,
    p_location_city,
    p_location_administrative_region);
    
    IF lv_location_id_out IS NULL THEN
        err_msg_txt := 'Invalild value for parameter ' || lv_location_id_out ||', in context with CREATE_ORGANIZATION_SP';
        RAISE ex_error;
    END IF;

OPEN chk_org_id;
FETCH chk_org_id INTO lv_chk_id;
IF chk_org_id%FOUND THEN
    
INSERT INTO VM_CREATE_OPPORTUNITY (
    OPPORTUNITY_ID,
    OPPORTUNITY_TITLE,
    OPPORTUNITY_DESCRIPTION,
    OPPORTUNITY_CREATE_DATE,
    OPPORTUNITY_MAX_VOLUNTEERS,
    OPPORTUNITY_MIN_VOLUNTEER_AGE,
    OPPORTUNITY_START_DATE,
    OPPORTUNITY_START_TIME,
    OPPORTUNITY_END_DATE,
    OPPORTUNITY_END_TIME,
    OPPORTUNITY_STATUS,
    OPPORTUNITY_GREAT_FOR,
    LOCATION_ID,
    ORGANIZATION_ID,
    PERSON_ID)
    VALUES (
    p_opp_id,
    p_opp_title,
    p_opp_description,
    p_opp_create_date,
    p_opp_max_volunteers,
    p_opp_min_volunteer_age,
    p_opp_start_date,
    p_opp_start_time,
    p_opp_end_date,
    p_opp_end_time,
    p_opp_status,
    p_opp_great_for,
    lv_location_id_out,
    p_org_id,
    lv_person_id_out)
    
    RETURNING p_opp_id INTO inserted_id;
    DBMS_OUTPUT.PUT_LINE('Newly created data, has the PERSON_ID = '||inserted_id);

ELSIF chk_org_id%NOTFOUND THEN
    err_msg_txt := 'The value of the p_org_id parameter does not match which is ' || lv_chk_id ||', thus, no data are inserted';
    RAISE ex_error;
END IF;    
    CLOSE chk_org_id; 

/*EXCEPTION SECTION*/
Exception
when ex_error then
dbms_output.put_line(err_msg_txt);
rollback;
when others then
dbms_output.put_line(' the error code is: ' || sqlcode);
dbms_output.put_line(' the error msg is: ' || sqlerrm);
rollback;
    
END CREATE_OPPORTUNITY_PP;

PROCEDURE ADD_ORG_CAUSE_PP (
    p_org_id            VM_ORGCAUSE.ORGANIZATION_ID%TYPE,    -- NOT NULL
    p_cause_name        VM_ORGCAUSE.CAUSE_NAME%TYPE -- NOT NULL
)
IS

ex_error exception;
err_msg_txt varchar(250) :=null;
lv_org_id NUMBER;
lv_count NUMBER;

BEGIN

SELECT COUNT (ORGANIZATION_ID) INTO lv_org_id FROM VM_ORGANIZATION WHERE ORGANIZATION_ID = p_org_id;
    IF lv_org_id IS NULL THEN
        err_msg_txt := 'Missing mandatory value for parameter ' || p_org_id || ', in context ADD_ORG_CAUSE_SP';
        RAISE ex_error; 
            
        ELSIF lv_org_id = 0 THEN 
        err_msg_txt := 'Invalid value for parameter ' || p_org_id || ', in context ADD_ORG_CAUSE_SP.
        No such ID is found in VM_ORGANIZATION';
        RAISE ex_error;
    END IF;

SELECT COUNT(*) INTO lv_count FROM VM_CAUSE WHERE CAUSE_NAME = p_cause_name;
    IF lv_count IS NULL THEN
        err_msg_txt := 'Missing mandatory value for parameter ' || p_cause_name ||', in context ADD_ORG_CAUSE_SP';
        RAISE ex_error;
    
        ELSIF lv_count = 0 THEN
        err_msg_txt := 'Invalid value for parameter ' || p_cause_name ||', in context ADD_ORG_CAUSE_SP.
        No such name is found in VM_CAUSE';
        RAISE ex_error;
    END IF;

    INSERT INTO VM_ORGCAUSE ("ORGANIZATION_ID", "CAUSE_NAME")
    VALUES (p_org_id, p_cause_name);
    COMMIT;

EXCEPTION
    WHEN ex_error THEN
    dbms_output.put_line(err_msg_txt);
    ROLLBACK;
    WHEN OTHERS THEN
    dbms_output.put_line(' the error code is: ' || sqlcode);
    dbms_output.put_line(' the error msg is: ' || sqlerrm);
    ROLLBACK;

END ADD_ORG_CAUSE_PP;

PROCEDURE ADD_MEMBER_CAUSE_PP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_cause_name    IN  VARCHAR     -- NOT NULL
    )
    
IS

p_count number;
p_count_id number;
ex_error exception;
err_msg_txt varchar(200) :=null;

BEGIN

select count (PERSON_ID)
into p_count_id 
from VM_PERSON
where PERSON_ID = p_person_id;

if p_person_id is null then
err_msg_txt := 'Missing mandatory value for parameter PERSON_ID in context ADD_MEMBER_CAUSE_SP';
raise ex_error;

elsif p_count_id = 0 
then 
err_msg_txt := 'Invalid value for parameter p_person_id in context ADD_MEMBER_CAUSE_SP.
The skill name is not found in VM_PERSON.';
raise ex_error;
end if;

select count (*)
into p_count 
from VM_MEMCAUSE
where p_cause_name = CAUSE_NAME;

if p_cause_name is null then
err_msg_txt := 'Missing mandatory value for parameter CAUSE_NAME in context ADD_MEMBER_CAUSE_SP';
raise ex_error;

if p_count = 0 
then 
err_msg_txt := 'Invalid value for parameter p_cause_name in context ADD_OPP_SKILL_SP.
The cause name is not found in VM_MEMCAUSE.';
raise ex_error;
end if;

    INSERT INTO VM_MEMCAUSE ("PERSON_ID", "CAUSE_NAME")
    VALUES (p_person_id, p_cause_name);
    COMMIT;

Exception
    when ex_error then
    dbms_output.put_line(err_msg_txt);
    rollback;
    when others then
    dbms_output.put_line(' the error code is: ' || sqlcode);
    dbms_output.put_line(' the error msg is: ' || sqlerrm);
    rollback;

END ADD_MEMBER_CAUSE_PP;

PROCEDURE ADD_OPP_SKILL_PP (
    p_opp_id        IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR     -- NOT NULL
    )
IS

p_count number;
p_count_id number;
ex_error exception;
err_msg_txt varchar(200) :=null;

BEGIN

select count (OPPORTUNITY_ID)
into p_count_id 
from VM_OPPORTUNITY
where OPPORTUNITY_ID = p_opp_id;

if p_opp_id is null then
err_msg_txt := 'Missing mandatory value for parameter OPPORTUNITY_ID in context ADD_OPP_SKILL_SP';
raise ex_error;

elsif p_count_id = 0 
then 
err_msg_txt := 'Invalid value for parameter p_opp_id in context ADD_OPP_SKILL_SP.
The skill name is not found in VM_OPPORTUNITY.';
raise ex_error;
end if;

select count (*)
into p_count 
from VM_SKILL
where p_skill_name = SKILL_NAME;

if p_skill_name is null then
err_msg_txt := 'Missing mandatory value for parameter SKILL_NAME in context ADD_OPP_SKILL_SP';
raise ex_error;

elsif p_count = 0 
then 
err_msg_txt := 'Invalid value for parameter p_skill_name in context ADD_OPP_SKILL_SP.
The skill name is not found in VM_SKILL.';
raise ex_error;
end if;

    INSERT INTO VM_OPPSKILL ("OPPORTUNITY_ID", "SKILL_NAME")
    VALUES (p_opp_id, p_skill_name);
    COMMIT;

Exception
    when ex_error then
    dbms_output.put_line(err_msg_txt);
    rollback;
    when others then
    dbms_output.put_line(' the error code is: ' || sqlcode);
    dbms_output.put_line(' the error msg is: ' || sqlerrm);
    rollback;

END ADD_OPP_SKILL_PP;

PROCEDURE ADD_MEMBER_SKILL_PP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR -- NOT NULL
)

IS

p_count number;
p_count_id number;
ex_error exception;
err_msg_txt varchar(200) :=null;

BEGIN

select count (PERSON_ID)
into p_count_id
from VM_PERSON
where PERSON_ID = p_person_id;

if p_person_id is null then
err_msg_txt := 'Missing mandatory value for parameter PERSON_ID in context ADD_MEMBER_SKILL_SP';
raise ex_error; 

elsif p_count_id = 0 
then 
err_msg_txt := 'Invalid value for parameter p_person_id in context ADD_MEMBER_SKILL_SP.
The ID number is not found in VM_PERSON.';
raise ex_error;
end if;

select count (*)
into p_count 
from VM_SKILL
where p_skill_name = SKILL_NAME;

if p_skill_name is null then
err_msg_txt := 'Missing mandatory value for parameter SKILL_NAME in context ADD_MEMBER_SKILL_SP';
raise ex_error;

elsif p_count = 0 
then 
err_msg_txt := 'Invalid value for parameter p_skill_name in context ADD_MEMBER_SKILL_SP.
The skill name is not found in VM_SKILL.';
raise ex_error;
end if;

    INSERT INTO VM_MEMSKILL ("PERSON_ID", "SKILL_NAME")
    VALUES (p_person_id, p_skill_name);
    COMMIT;

Exception
    when ex_error then
    dbms_output.put_line(err_msg_txt);
    rollback;
    when others then
    dbms_output.put_line(' the error code is: ' || sqlcode);
    dbms_output.put_line(' the error msg is: ' || sqlerrm);
    rollback;


END ADD_MEMBER_SKILL_PP;

END volunteer3a_pkg;
/
