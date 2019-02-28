create or replace PROCEDURE CREATE_ORGANIZATION_SP (
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
SELECT count (*)INTO lv_person_id_out FROM VM_PERSON where lv_person_id_out = PERSON_ID;

CREATE_PERSON_SP(lv_person_id_out, p_person_email, P_person_given_name, p_person_surname, p_person_phone);
    IF lv_person_id_out IS NULL THEN
        err_msg_txt := 'Invalild value for parameter ' || lv_person_id_out ||', in context with CREATE_ORGANIZATION_SP';
        RAISE ex_error;
    END IF;
    
/*CREATING LOCATION THROUGH CALLING LOCATION PROCEDURE*/
SELECT count (*)INTO lv_location_id_out FROM VM_LOCATION WHERE lv_location_id_out = LOCATION_ID;
create_location_sp(p_location_country,p_location_postal_code,p_location_street1,p_location_street2,p_location_city,p_location_administrative_region);
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
    INSERT INTO VM_ORGANIZATION (ORGANIZATION_ID,ORGANIZATION_NAME,ORGANIZATION_MISSION_STATEMENT,ORGANIZATION_DESCRIPTION,ORGANIZATION_PHONE,ORGANIZATION_TYPE,ORGANIZATION_CREATION_DATE,ORGANIZATION_URL,ORGANIZATION_IMAGE_URL,ORGANIZATION_LINKEDIN_URL,ORGANIZATION_FACEBOOK_URL,ORGANIZATION_TWITTER_URL,PERSON_ID,LOCATION_ID)

    VALUES (lv_henter_verdi,p_org_name,p_org_mission,p_org_descrip,p_org_phone,p_org_type,p_org_creation_date,p_org_URL,p_org_image_URL,p_org_linkedin_URL,p_org_facebook_URL,p_org_twitter_URL,lv_person_id_out,lv_location_id_out);

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

END;
/
/*CREATING NEW ORGANIZATION*/
BEGIN
  CREATE_ORGANIZATION_SP('CnP Education','CnP Education creates a safe and ideal environment where international students can overcome their educational challenges and reach their full potential. ','Providing them purpose, vision, direction and motivation for students who are achieving their goals, EnB Education will inspire, influences and empower our students to become leaders of their generations.', '+1 (215) 375-8687','other organization',to_date('27/FEB/19','DD-MON-RR'),'https://www.cnpeducation.com/%27','www.cnpimage.com','www.linkedIn.com/cnpeducation','www.facebook.com/cnpeducation','www.twitter.com/cnpeducation','Norway','4631','BrinGken','49B','KristiansandG S','Vest-Agder','newrson@gmail.com','Kristian','Karlsen','96554332');
END;
/
