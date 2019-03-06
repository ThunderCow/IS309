CREATE OR REPLACE PACKAGE volunteer3a_pkg
IS
PROCEDURE CREATE_PERSON_PP (
        p_person_id         OUT VM_PERSON.PERSON_ID%TYPE,
        p_person_email      IN  VM_PERSON.PERSON_EMAIL%TYPE,
        P_person_given_name IN  VM_PERSON.PERSON_GIVEN_NAME%TYPE,
        p_person_surname    IN  VM_PERSON.PERSON_SURNAME%TYPE,
        p_person_phone      IN  VM_PERSON.PERSON_PHONE%TYPE
    );
PROCEDURE CREATE_LOCATION_PP (
        p_location_id             OUT     VM_LOCATION.LOCATION_ID%TYPE,                     -- an output parameter
        p_location_country	     IN        VM_LOCATION.LOCATION_COUNTRY%TYPE, 
        p_location_postal_code    IN         VM_LOCATION.LOCATION_POSTAL_CODE%TYPE,
        p_location_street1	    IN         VM_LOCATION.LOCATION_STREET_1%TYPE, 
        p_location_street2	    IN         VM_LOCATION.LOCATION_STREET_2%TYPE, 
        p_location_city	        IN         VM_LOCATION.LOCATION_CITY%TYPE, 
        p_location_administrative_region IN   VM_LOCATION.LOCATION_ADMINISTRATIVE_REGION%TYPE
    );
END volunteer3a_pkg;
/
