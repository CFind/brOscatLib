FUNCTION LANGEVIN
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=58*)
    IF X = 0.0 THEN
    	LANGEVIN := 0.0;
    ELSE
    	LANGEVIN := COTH(X) - 1.0 / X;
    END_IF

    (* revision history
    hm	10.12.2007	rev 1.0
    	original version

    hm	11. mar 2008	rev 1.1
    	changed formula to avoid problems when X = 0

    hm	10. mar. 2009	rev 1.2
    	real constants updated to new systax using dot

    *)
END_FUNCTION
