FUNCTION V3_ANG
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=109*)
    d := V3_ABS(A) * V3_ABS(B);
    IF d > 0 THEN
    	V3_ANG := ACOS(LIMIT(-1.0, V3_DPRO(A, B) / d,1.0));
    END_IF

    (* revision history
    hm	11. dec. 2007	rev 1.0
    	original version

    hm	10. mar. 2009	rev 1.1
    	changed syntax of real constants to 0.0

    *)
END_FUNCTION
