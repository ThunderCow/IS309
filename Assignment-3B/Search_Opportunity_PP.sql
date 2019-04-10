CREATE OR REPLACE PROCEDURE SEARCH_OPPORTUNITIES_PP (
    p_member_email      IN VARCHAR      -- Must not be NULL
)
IS

exc_oppr EXCEPTION;
err_msg_txt VARCHAR(150);
lv_get_oppr     VM_OPPORTUNITY.OPPORTUNITY_ID%TYPE;
lv_get_mem_email /*VM_PERSON.PERSON_EMAIL%TYPE*/ VARCHAR(50);


/*PREPARING A CUROSR FOR RETRIEVING OPPORTUNITY_ID*/
CURSOR ret_oppr IS
SELECT
    "A1"."OPPORTUNITY_ID" "OPPORTUNITY_ID"
FROM
    "OHAMATECH"."VM_OPPORTUNITY" "A1"
WHERE
    "A1"."PERSON_ID" = "A1"."PERSON_ID";

/*PREPARING A CUROSR FOR RETRIEVING MEM_EMAIL*/
CURSOR ret_mem_email IS
 SELECT
        PERSON_EMAIL
    FROM
        VM_PERSON
    WHERE
        PERSON_EMAIL = p_member_email;

/*PREPARING A CUROSR AND PROVIDING CERTAIN COLUMNS TO RETRIEVE THEIR DATA*/
CURSOR get_cause_skill IS
    SELECT
    "A3"."OPPORTUNITY_ID"   "OPPORTUNITY_ID",
    "A2"."CAUSE_NAME"       "CAUSE_NAME",
    "A1"."SKILL_NAME"       "SKILL_NAME",
    RANK() OVER(
        PARTITION BY "A3"."OPPORTUNITY_ID"
        ORDER BY
            "A2"."CAUSE_NAME", "A1"."SKILL_NAME" DESC
    ) "RANK"
FROM
    "OHAMATECH"."VM_OPPORTUNITY"   "A3",
    "OHAMATECH"."VM_MEMCAUSE"      "A2",
    "OHAMATECH"."VM_MEMSKILL"      "A1"
WHERE
    "A3"."PERSON_ID" = "A2"."PERSON_ID"
    OR "A3"."PERSON_ID" = "A1"."PERSON_ID";
lv_get_all_detail get_cause_skill%ROWTYPE;
/*lv_get_oppr_id VM_OPPORTUNITY.OPPORTUNITY_ID%TYPE;
lv_get_cause_name VM_MEMCAUSE.CAUSE_NAME%TYPE;
lv_get_skill_name VM_MEMSKILL.SKILL_NAME%TYPE;
lv_rank NUMBER;*/

BEGIN

/*CHECKING IF MEM_EMAIL IS NULL*/
IF p_member_email IS NULL THEN
    err_msg_txt := 'MISSING MANDATORY VALUE FOR PARAMETER "P_MEMBER_EMAIL" IN GET_SERACH_OPPORTUNITY_PP';
    RAISE exc_oppr;
END IF;

/*RETRIEVING MEM_EMAIL BY OPENING CURSOR AND RAISE EXCEPTION WHEN NOT FOUND*/
OPEN ret_mem_email;
FETCH ret_mem_email INTO lv_get_mem_email;
IF(ret_mem_email%NOTFOUND) THEN
    err_msg_txt := 'MEMBER: '|| p_member_email || ' NOT FOUND';
    RAISE exc_oppr;
END IF;
CLOSE ret_mem_email;

/*RETRIEVING OPPORTUNITY BY OPENING CURSOR*/
OPEN ret_oppr;
FETCH ret_oppr INTO lv_get_oppr;
IF (ret_oppr%FOUND) THEN
    DBMS_OUTPUT.PUT_LINE( 'LIST OF ALL OPPORTUNITIES: ' ||  lv_get_oppr);
ELSE
    err_msg_txt := 'NO SUCH OPPORTUNITY EXISTS IN DB SYSTEM';
    RAISE exc_oppr;
END IF;
CLOSE ret_oppr;

/*CURSOR OPENING AND FETCHING DATA TIL NO FURTHER DATA FOUND*/
OPEN get_cause_skill;
LOOP
    FETCH get_cause_skill INTO lv_get_all_detail /*lv_get_oppr_id, lv_get_cause_name, lv_get_skill_name, lv_rank*/;
    DBMS_OUTPUT.PUT_LINE( 'OPPORTUNITY_ID: ' || lv_get_all_detail.opportunity_id ||' CAUSE_NAMES: ' || lv_get_all_detail.cause_name || ' SKILL_NAMES: ' || lv_get_all_detail.skill_name || ' Rank: ' || lv_get_all_detail.rank);
    EXIT WHEN get_cause_skill%NOTFOUND;
END LOOP;

/*RAISE EXCEPTION WHEN MATCHING DATA FOUND*/
IF(get_cause_skill%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
END IF;
CLOSE get_cause_skill;

/*EXCEPTION BODY*/
EXCEPTION
    WHEN exc_oppr THEN
        DBMS_OUTPUT.PUT_LINE(err_msg_txt);
        ROLLBACK;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('SORRY, NO MATCHING DATA FOUND FURTHER');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('THE ERROR CODE IS' ||SQLCODE);
        DBMS_OUTPUT.PUT_LINE('THE ERROR MSG IS' ||SQLERRM);
        ROLLBACK;
END;

/*TESTING SECTION*/
BEGIN
    SEARCH_OPPORTUNITIES_PP('jackson@aol.com');
END;