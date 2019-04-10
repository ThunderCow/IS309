CREATE OR REPLACE PROCEDURE RECORD_HOURS_PP (
    p_member_email      IN  VARCHAR,    -- Not NULL
    p_opportunity_id    IN  VARCHAR,    -- NOT NULL
    p_hours             IN  NUMBER,     -- NOT NULL
    p_volunteer_date    IN  DATE        -- NOT NULL
)
IS
    creation_date  DATE := current_date;
    p_status   VARCHAR2(30) := 'pending';
    approval_id VM_TIMESHEET.APPROVER_ID%TYPE;
    
    ex_record EXCEPTION;
    err_msg_txt VARCHAR(200);
    
    lv_mem_id_out          VM_PERSON.PERSON_ID%TYPE;
    lv_opprt_id_out        VM_OPPORTUNITY.OPPORTUNITY_ID%TYPE;
    lv_volunt_date_out     VM_TIMESHEET.TIMESHEET_VOLUNTEER_DATE%TYPE;
    
/*PREPARING CURSOR FOR RETRIEVING MEM_EMAIL*/
CURSOR ret_mem_id IS
    SELECT
        VM_MEMBER.PERSON_ID
    FROM
        VM_MEMBER, VM_PERSON
    WHERE
        PERSON_EMAIL = p_member_email AND  VM_MEMBER.PERSON_ID = VM_PERSON.PERSON_ID;

/*PREPARING CURSOR FOR RETRIEVING OPPRTUNITY_ID*/    
CURSOR ret_opprt_id IS
    SELECT
        VM_OPPORTUNITY.OPPORTUNITY_ID
    FROM
        VM_OPPORTUNITY
    WHERE
        OPPORTUNITY_ID = p_opportunity_id;

/*PREPARING CURSOR FOR RETRIEVING RECORD*/    
CURSOR ret_record IS
    SELECT
        TIMESHEET_VOLUNTEER_DATE
    FROM
        VM_TIMESHEET
    WHERE
      TIMESHEET_VOLUNTEER_DATE = p_volunteer_date AND OPPORTUNITY_ID = p_opportunity_id;
    
BEGIN
/*CHECKING NULLABLE VALUES FOR DIFFERENT PARAMTERS*/
IF p_member_email IS NULL THEN
    err_msg_txt := 'Missing mandatory value for parameter P_MEMBER_EMAIL, no hours added';
    RAISE ex_record;
END IF;

IF p_opportunity_id IS NULL THEN
    err_msg_txt := 'Missing mandatory value for parameter P_OPPORTUNITY_ID, no hours added';
    RAISE ex_record;
END IF;

IF p_hours IS NULL THEN
    err_msg_txt := 'Missing mandatory value for parameter P_HOURS, no hours added';
    RAISE ex_record;
END IF;
    
IF p_volunteer_date IS NULL THEN
    err_msg_txt := 'Missing mandatory value for parameter P_VOLUNTEER_DATE, no hours added';
    RAISE ex_record;
END IF;

/*OPENING CURSOR AND FETCHING MEM_EMAIL AND RAISE EXCEPTION WHEN NO DATA FOUND*/
OPEN ret_mem_id;
FETCH ret_mem_id INTO lv_mem_id_out;
IF(ret_mem_id%NOTFOUND)THEN
    err_msg_txt := 'MEMBER WITH THIS ID' ||lv_mem_id_out|| 'NOT FOUND. NO HOURSE ADDED';
    RAISE ex_record;
END IF;
CLOSE ret_mem_id;

/*OPENING CURSOR AND FETCHING OPPRT_ID AND RAISE EXCEPTION WHEN NO DATA FOUND*/
OPEN ret_opprt_id;
FETCH ret_opprt_id INTO lv_opprt_id_out;
IF(ret_opprt_id%NOTFOUND) THEN
    err_msg_txt := 'MISSING OPPORTUNITY. NO COMMITMENT ADDED';
    RAISE ex_record;
END IF;
CLOSE ret_opprt_id;

/*CHECKING IF HOURS_VALUE IS IN LIMIT AND RAISE EXCEPTION WHEN IT IS NOT*/
IF p_hours < 1 OR p_hours>24 THEN
err_msg_txt := 'Invalid number of hours for opportunity: ' ||p_opportunity_id||'.' ||' Must be a number between 1 and 24 hours.';
RAISE ex_record;
END IF;

/*OPENING CURSOR AND FETCHING DATE DATA AND RAISE EXCEPTION WHEN DATA ALREADY EXISTED*/
OPEN ret_record;
FETCH ret_record INTO lv_volunt_date_out;
IF(ret_record%FOUND) THEN
DBMS_OUTPUT.PUT_LINE( 'RECORD HAS ALREADY BEEN MADE FOR THIS DATE' || p_volunteer_date);

/*INSERTING VALUES WHEN RECORD IN NEW*/
ELSE
    INSERT INTO VM_TIMESHEET ("TIMESHEET_VOLUNTEER_DATE","TIMESHEET_VOLUNTEER_HOURS","TIMESHEET_CREATION_DATE","TIMESHEET_STATUS","APPROVER_ID","OPPORTUNITY_ID","PERSON_ID")
    VALUES (p_volunteer_date, p_hours, creation_date, p_status, approval_id, p_opportunity_id, lv_mem_id_out);
    DBMS_OUTPUT.PUT_LINE( 'A NEW RECORD HAS BEEN MADE FOR THE DATE' || p_volunteer_date);
END IF;
COMMIT;

CLOSE ret_record;

/*EXCEPTION BODY*/
EXCEPTION
    WHEN ex_record THEN
        DBMS_OUTPUT.PUT_LINE(err_msg_txt);
    ROLLBACK;
WHEN
    NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('SORRY, NO DATA FOUND');
    ROLLBACK;
WHEN
    OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('THE ERROR CODE IS: ' ||SQLCODE);
        DBMS_OUTPUT.PUT_LINE('THE ERROR MSG IS: ' ||SQLERRM);
    ROLLBACK;
END;

/*TESTING SECTION*/
BEGIN
    RECORD_HOURS_PP('jackson@aol.com', 1,4, TO_DATE('2019-02-06', 'yyyy-mm-dd'));
END;
