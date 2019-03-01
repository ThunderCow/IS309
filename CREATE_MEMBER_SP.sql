/*
CREATE_MEMBER_SP.  This procedure will create a new member by inserting a row into the VM_PERSON and VM_MEMBER tables.
The procedure will use CREATE_PERSON_SP procedure for the former. The primary key generated when inserting into the VM_PERSON
table will be used as the primary key value for the row inserted into the VM_MEMBER table.
The procedure will also call CREATE_LOCATION_SP to store the location data provided.
*/

CREATE OR REPLACE PROCEDURE CREATE_MEMBER_SP(
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


END;
/

DECLARE
  oId NUMBER;
BEGIN
  CREATE_MEMBER_SP(oId,'lolhhdshhh', 'testtsdfest@tddest.com', 'perdsfpdal', 'pallsdfedsen', '393393939', 'Norway', '3984', 'djjdjdj', 'jdjdjjd', 'Kristsand', 'Agder');
END;
  /
