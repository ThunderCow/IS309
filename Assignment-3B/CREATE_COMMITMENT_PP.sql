Create or replace procedure CREATE_COMMITMENT_PP (
    p_commitment_id     OUT INTEGER,    -- Output parameter
    p_member_email      IN  VARCHAR,    -- Not NULL
    p_opportunity_id    IN  VARCHAR,    -- Not NULL
    p_start_date        IN  DATE,       
    p_end_date          IN  DATE
    )
    is 
    
    ex_error exception;
    err_msg_txt VARCHAR(200);
    lv_person_email_out          vm_person.person_email%TYPE;
    lv_person_ID_out                vm_member.person_id%TYPE;
    lv_opp_id_out                VM_OPPORTUNITY.OPPORTUNITY_ID%TYPE;
    lv_start_date                 date; 
    lv_end_date                   date;
    lv_comm_id                    VM_COMMITMENT.COMMITMENT_ID%TYPE;
    
    
    CURSOR retr_person_email IS
    SELECT
        VM_PERSON.PERSON_EMAIL
    FROM
        VM_PERSON
    WHERE
        PERSON_EMAIL = p_member_email;
           
    
    CURSOR retr_commitment_id_1 IS
    SELECT
        VM_COMMITMENT.COMMITMENT_ID
    FROM
        VM_COMMITMENT
    WHERE
         OPPORTUNITY_ID = p_opportunity_id ;
         
         
    CURSOR retr_commitment_id_2 IS
    SELECT
        VM_COMMITMENT.COMMITMENT_ID
    FROM
        VM_COMMITMENT
    WHERE COMMITMENT_START_DATE = p_start_date;
    
    
    CURSOR retr_commitment_id_3 IS
    SELECT
        VM_COMMITMENT.COMMITMENT_ID
    FROM
        VM_COMMITMENT
    WHERE COMMITMENT_END_DATE = p_end_date;
    
    
    CURSOR retr_commitment_id_4 IS
    SELECT
        VM_COMMITMENT.COMMITMENT_ID
    INTO lv_comm_id
    FROM
        VM_COMMITMENT
    WHERE PERSON_ID =  (SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_member_email); 
    
    
    CURSOR retr_data IS
    SELECT OPPORTUNITY_ID, COMMITMENT_ID, PERSON_ID 
    from VM_COMMITMENT 
    WHERE OPPORTUNITY_ID = p_opportunity_id;
    
   
    begin 
    
    OPEN retr_person_id; 
    fetch retr_person_id into member_id;
    IF retr_person_ID%NOTFOUND THEN
        err_msg_txt := 'Member with email: ' || mem_email || ' does not exist';
        RAISE non_exsistable_id;
        
    END IF;
    CLOSE retr_person_ID;
    
    SELECT START_DATE 
    into lv_start_date 
    from VM_COMMITMENT 
    WHERE COMMITMENT_ID = lv_comm_id;
    
    
    SELECT END_DATE 
    into lv_end_date 
    from VM_COMMITMENT 
    WHERE COMMITMENT_ID = lv_comm_id;
    
    
    OPEN retr_data;
    
    
END;
    
    
    

    
