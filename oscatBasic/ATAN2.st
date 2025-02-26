FUNCTION ATAN2
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=40*)
    IF X > 0.0 THEN
    	ATAN2 := ATAN(Y/X);
    ELSIF X < 0.0 THEN
    	IF Y >=0.0 THEN
    		ATAN2 := ATAN(Y/X) + cPI;
    	ELSE
    		ATAN2 := ATAN(Y/X) - cPI;
    	END_IF
    ELSIF Y > 0.0 THEN
    	ATAN2 := cPI05;
    ELSIF Y < 0.0 THEN
    	ATAN2 := -cPI05;
    ELSE
    	ATAN2 := 0.0;
    END_IF


    (* revision history
    hm	20.  apr. 2008	rev 1.0
    	original version

    hm	18. oct. 2008	rev 1.1
    	changed to use math constants

    hm	10. mar. 2009	rev 1.2
    	real constants updated to new systax using dot

    *)

END_FUNCTION
