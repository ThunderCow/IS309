/*
GET_MEMBER_HOURS_PF. Given a member email address, an opportunity ID, a start
date and an end date, calculate the number of hours worked.  The start date and
end date can be NULL.  If both are NULL, then calculate the hours worked on this
opportunity for all dates.
PARAMETERS:     Described below
RETURNS:        Calculated hours, or NULL
ERROR MESSAGES:
  Error text:  "Missing mandatory value for parameter (x) in GET_MEMBER_HOURS_PF."
           x = a mandatory parameter that is NULL
  Error meaning: A mandatory parameter is NULL.
  Error effect:  NULL value returned.

  Error text:  "Member (x) not found."
           x = email address
  Error meaning: The member with the given email address cannot be found in the system.
  Error effect:  NULL value returned.

  Error text:  "Opportunity (x) not found."
           x = opportunity id
  Error meaning: The opportunity with the given id value cannot be found in the system.
  Error effect:  NULL value returned.

  Error text:  "End date (x) must be later than the start date (y)"
           x = the end date
           y = the start date
  Error meaning:  The start date of the range of dates can't be after the end date.
  Error effect:  NULL value returned.


*/
CREATE OR REPLACE FUNCTION get_member_hours(mem_email IN VARCHAR,
opp_id IN NUMBER,
start_date IN DATE,
end_date IN DATE)

RETURN float
IS
  missing_mand_value exception;
  non_exsistable_id exception;
  startdate_after_enddate exception;
  err_msg_txt VARCHAR(150) := '';
  chk_pr_id NUMBER;
  total_hours number := 0;

  cursor chk_mem_ID is
  SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = mem_email;

  cursor chk_opp_ID is
  SELECT OPPORTUNITY_ID FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = opp_id;
BEGIN
  OPEN chk_mem_ID;
FETCH chk_mem_ID INTO chk_pr_id;
    IF chk_mem_ID%NOTFOUND THEN
        err_msg_txt := 'Member with email: ' || mem_email || ' does not exist';
        RAISE non_exsistable_id;
    END IF;
    CLOSE chk_mem_ID;

OPEN chk_opp_ID;
FETCH chk_opp_ID INTO chk_pr_id;
    IF chk_opp_ID%NOTFOUND THEN
        err_msg_txt := 'Opportunity with id: ' || opp_id || ' does not exist';
        RAISE non_exsistable_id;
    END IF;
    CLOSE chk_opp_ID;
IF start_date > end_date THEN
  err_msg_txt := 'Startdate cannot be after enddate';
  raise startdate_after_enddate;
end if;

IF mem_email is null then
  err_msg_txt := 'Missing mandatory value for parameter, mem_email  can not be null.
  The hours worked value returned is NULL.  ';
  raise missing_mand_value;

ELSIF opp_id is null then
  err_msg_txt := 'Missing mandatory value for parameter, opp_id  can not be null.
  The hours worked value returned is NULL.  ';
  raise missing_mand_value;
END IF;

IF start_date is null AND end_date is null THEN
  SELECT SUM(TIMESHEET_VOLUNTEER_HOURS) INTO total_hours FROM VM_MEMBER
  LEFT JOIN VM_PERSON ON VM_MEMBER.PERSON_ID = VM_PERSON.PERSON_ID
  LEFT JOIN VM_TIMESHEET ON VM_MEMBER.PERSON_ID = VM_TIMESHEET.PERSON_ID
  WHERE VM_PERSON.PERSON_EMAIL = mem_email AND OPPORTUNITY_ID = opp_id;
ELSIF start_date is null AND end_date is not null THEN
  SELECT SUM(TIMESHEET_VOLUNTEER_HOURS) INTO total_hours FROM VM_MEMBER
  LEFT JOIN VM_PERSON ON VM_MEMBER.PERSON_ID = VM_PERSON.PERSON_ID
  LEFT JOIN VM_TIMESHEET ON VM_MEMBER.PERSON_ID = VM_TIMESHEET.PERSON_ID
  WHERE VM_PERSON.PERSON_EMAIL = mem_email AND OPPORTUNITY_ID = opp_id AND TIMESHEET_VOLUNTEER_DATE < end_date;
ELSIF start_date is not null AND end_date is null THEN
  SELECT SUM(TIMESHEET_VOLUNTEER_HOURS) INTO total_hours FROM VM_MEMBER
  LEFT JOIN VM_PERSON ON VM_MEMBER.PERSON_ID = VM_PERSON.PERSON_ID
  LEFT JOIN VM_TIMESHEET ON VM_MEMBER.PERSON_ID = VM_TIMESHEET.PERSON_ID
  WHERE VM_PERSON.PERSON_EMAIL = mem_email AND OPPORTUNITY_ID = opp_id AND TIMESHEET_VOLUNTEER_DATE > start_date;
ELSIF start_date is not null AND end_date is not null THEN
  SELECT SUM(TIMESHEET_VOLUNTEER_HOURS) INTO total_hours FROM VM_MEMBER
  LEFT JOIN VM_PERSON ON VM_MEMBER.PERSON_ID = VM_PERSON.PERSON_ID
  LEFT JOIN VM_TIMESHEET ON VM_MEMBER.PERSON_ID = VM_TIMESHEET.PERSON_ID
  WHERE VM_PERSON.PERSON_EMAIL = mem_email AND OPPORTUNITY_ID = opp_id AND TIMESHEET_VOLUNTEER_DATE > start_date AND TIMESHEET_VOLUNTEER_DATE < end_date;
END IF;

return total_hours;
EXCEPTION
  WHEN missing_mand_value THEN
    dbms_output.put_line(err_msg_txt);
    return null;
  WHEN non_exsistable_id THEN
    dbms_output.put_line(err_msg_txt);
    return null;
  WHEN startdate_after_enddate THEN
    dbms_output.put_line(err_msg_txt);
    return null;
END get_member_hours;


  BEGIN
    dbms_output.put_line(get_member_hours('jackson@aol.com',1,to_date('2019-02-01', 'yyyy-mm-dd'),to_date('2019-02-03','yyyy-mm-dd')));
  end;
