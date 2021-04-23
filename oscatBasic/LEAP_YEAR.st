FUNCTION LEAP_YEAR
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=127*)
    LEAP_YEAR := SHL(yr,14) = 0;

    (* this code was used prior to rev 1.1

    IF yr MOD 400 = 0 THEN leap_year := TRUE;
    ELSIF yr MOD 100 = 0 THEN leap_year := FALSE;
    ELSIF yr MOD 4 =0 THEN leap_year := TRUE;
    ELSE leap_year := FALSE;
    END_IF

    *)

    (* change history

    hm 	2.10.2006		rev 1.1
    	the function now works for any year from 1970 up to 2100

    hm	1. oct 2007		rev 1.2
    	chaged code for higher performance
    *)
END_FUNCTION