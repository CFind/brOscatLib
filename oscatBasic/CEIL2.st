FUNCTION CEIL2
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=44*)
    CEIL2 := REAL_TO_DINT(X);
    IF DINT_TO_REAL(CEIL2) < X THEN
    	CEIL2 := CEIL2 + 1;
    END_IF


    (* revision history
    hm	21. mar. 2008	rev 1.0
    	original version

    hm	4. apr. 2008	rev 1.1
    	added type conversion to avoid warnings under codesys 3.0

    hm	30. jun. 2008	rev 1.2
    	added type conversion to avoid warnings under codesys 3.0

    hm	10. mar. 2009	rev 1.3
    	use correct statement real_to_DINT

    *)

END_FUNCTION
