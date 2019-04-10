CREATE OR REPLACE PROCEDURE  APPROVE_HOURS_PP (
    p_member_email      IN VARCHAR,    -- Must not be NULL.
    p_approver_email    IN VARCHAR,    -- Must not be NULL.  Approver is a member.
    p_opportunity_id    IN VARCHAR,    -- Must not be NULL.
    p_volunteer_date    IN DATE,
    p_approval_status   IN VARCHAR    -- Must not be NULL.
)

IS
excp_app_hour EXCEPTION;
err_msg_txt VARCHAR(200);

lv_get_member_email VM_PERSON.PERSON_EMAIL%TYPE;
lv_get_oppr_id      VM_OPPORTUNITY.PERSON_ID%TYPE;
lv_get_appr_email   VM_PERSON.PERSON_EMAIL%TYPE;
lv_get_appr_status  VM_TIMESHEET.TIMESHEET_STATUS%TYPE;

/*PREPARING CURSOR FOR RETRIEVING MEM_EMAIL*/
CURSOR get_mem_email IS
    SELECT
        PERSON_EMAIL
    FROM
        VM_PERSON
    INNER JOIN
        VM_TIMESHEET ON VM_PERSON.PERSON_ID = VM_TIMESHEET.PERSON_ID
    WHERE
        PERSON_EMAIL = p_member_email;

/*PREPARING CURSOR FOR RETRIEVING OPPORTUNITY_ID*/
CURSOR get_oppr_id IS
    SELECT
        VM_OPPORTUNITY.OPPORTUNITY_ID
    FROM
        VM_OPPORTUNITY
    WHERE
        OPPORTUNITY_ID = p_opportunity_id;
        
/*PREPARING CURSOR FOR RETRIEVING APPROVER_EMAIL*/
CURSOR get_appr_email IS
       SELECT
        PERSON_EMAIL
    FROM
        VM_PERSON
    WHERE
        PERSON_EMAIL = p_approver_email;
        
/*PREPARING CURSOR FOR RETRIEVING APPR_STATUS*/
CURSOR get_status IS
    SELECT
        TIMESHEET_STATUS
    FROM
        VM_TIMESHEET
    WHERE
        TIMESHEET_STATUS = p_approval_status
        AND p_approval_status = 'approved' OR p_approval_status = 'not approved' OR p_approval_status = 'pending';

/*PREPARING CURSOR FOR RETRIEVING MEM_ID, OPPORT_ID TO DO FURTHER OPERATION*/
CURSOR get_recorded_hours IS
    SELECT
        PERSON_ID,
        OPPORTUNITY_ID
    FROM
        VM_TIMESHEET
    WHERE
        VM_TIMESHEET.OPPORTUNITY_ID = p_opportunity_id;
        lv_get_record_hours get_recorded_hours%ROWTYPE;
    
BEGIN
/*CHECKING DIFFERENT PARAMETERS WHETHER MISSING VALUES AND RAISE EXCEPTIONS*/
    IF p_member_email IS NULL THEN
    err_msg_txt := 'MISSING MANDATORY VALUE FOR PARAMETER "P_MEMBER_EMAIL" IN APPROVE_HOURS_PP';
    RAISE excp_app_hour;
    
    ELSIF p_approver_email IS NULL THEN
    err_msg_txt := 'MISSING MANDATORY VALUE FOR PARAMETER "P_APPROVER_EMAIL" IN APPROVE_HOURS_PP';
    RAISE excp_app_hour;
    
    ELSIF p_opportunity_id IS NULL THEN
    err_msg_txt := 'MISSING MANDATORY VALUE FOR PARAMETER "P_OPPORTUNITY_ID" IN APPROVE_HOURS_PP';
    RAISE excp_app_hour;
    
    ELSIF p_approval_status IS NULL THEN
    err_msg_txt := 'MISSING MANDATORY VALUE FOR PARAMETER "P_APPROVAL_STATUS" IN APPROVE_HOURS_PP';
    RAISE excp_app_hour;
    END IF;
    
/*OPEN CURSOR, FETCHING DATA AND RAISE EXCEPTION IF NOT FOUND*/
OPEN get_mem_email;
FETCH get_mem_email INTO lv_get_member_email;
IF (get_mem_email%NOTFOUND) THEN
    err_msg_txt := 'Member: '||lv_get_member_email|| 'not found.';
    DBMS_OUTPUT.PUT_LINE('THE ENTERED VALUE IS: ' ||p_member_email );
    RAISE excp_app_hour;
    END IF;
CLOSE get_mem_email;

/*OPEN CURSOR FOR OPPR_ID, FETCHING DATA AND RAISE EXCEPTION IF NOT FOUND*/
OPEN get_oppr_id;
FETCH get_oppr_id INTO lv_get_oppr_id;
IF (get_oppr_id%NOTFOUND) THEN
    err_msg_txt := 'Opportunity: "P_OPPORTUNITY_ID" not found.';
    DBMS_OUTPUT.PUT_LINE('THE ENTERED VALUE IS: ' ||p_opportunity_id);
    RAISE excp_app_hour;
END IF;
CLOSE get_oppr_id;

/*OPEN CURSOR FOR APPR_EMAIL, FETCHING DATA AND RAISE EXCEPTION IF NOT FOUND*/
OPEN get_appr_email;
FETCH get_appr_email INTO lv_get_appr_email;
IF (get_appr_email%NOTFOUND) THEN
    err_msg_txt := 'APPROVER: "P_APPROVER_EMAIL" not found.';
    DBMS_OUTPUT.PUT_LINE('THE ENTERED VALUE IS: ' ||p_approver_email);
    RAISE excp_app_hour;
    END IF;
CLOSE get_appr_email;

/*OPEN CURSOR FOR GETTING STATUS, FETCHING DATA AND RAISE EXCEPTION IF NOT FOUND*/
OPEN get_status;
FETCH get_status INTO lv_get_appr_status;
IF (get_status%NOTFOUND) THEN
    err_msg_txt := 'INVALID VALUE OF "P_APPROVAL_STAUS" FOR APPROVAL STATUS.';
    DBMS_OUTPUT.PUT_LINE('THE ENTERED VALUE IN STATUS IS: ' ||p_approval_status );
    RAISE excp_app_hour;
    END IF;
CLOSE get_status;

/*OPEN CURSOR FOR RECORD, FETCHING DATA AND RAISE EXCEPTION IF NOT FOUND*/
OPEN get_recorded_hours;
FETCH get_recorded_hours INTO lv_get_record_hours;
IF (get_recorded_hours%NOTFOUND) THEN
    err_msg_txt := 'MEMBER "MEMBER_ID" HAS NO RECORED HOURS ON OPPORTUNITY "P_OPPORTUNITY_ID" ON "P_VOLUNTEER_DATE".';
   /*IN CASE OF SHOWING EXTRA INFORMATION WHAT THE USER HAS GIVEN DIFFERENT VALUES, 'DISABLED INTENTIONALLY.'
   DBMS_OUTPUT.PUT_LINE( 'GIVEN INPUT DETAIL:  MEMBER_ID: ' || lv_get_record_hours.person_id ||'OPPORTUNITY_ID: ' || lv_get_record_hours.opportunity_id );
   */
    RAISE excp_app_hour;
    
ELSIF (get_recorded_hours%FOUND) THEN
    UPDATE VM_TIMESHEET
        SET 
            VM_TIMESHEET.APPROVER_ID = 1,
            VM_TIMESHEET.TIMESHEET_STATUS = 'approved'
        WHERE
           VM_TIMESHEET.OPPORTUNITY_ID = p_opportunity_id;
           DBMS_OUTPUT.PUT_LINE( 'TMESHEET RECORD IS SUCCESSFULLY UPDATED AGAINST THIS OPPORTUNITY '||p_opportunity_id);
END IF;
        COMMIT;
CLOSE get_recorded_hours;
       
/*EXCEPTION BODY*/
EXCEPTION
    WHEN excp_app_hour THEN
        DBMS_OUTPUT.PUT_LINE(err_msg_txt);
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('THE ERROR CODE IS: ' ||SQLCODE);
        DBMS_OUTPUT.PUT_LINE('THE ERROR MSG IS: ' ||SQLERRM);
        ROLLBACK;
END;

/*TESTING SECTION*/
BEGIN
    APPROVE_HOURS_PP('jackson@aol.com', 'wolcott.peter@gmail.com',1,/*to_date('03-FEB-19', 'yy-mm-dd')*/null, 'pending');
END;
