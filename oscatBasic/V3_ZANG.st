FUNCTION V3_ZANG
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=113*)
    la := V3_ABS(a);
    IF la > 0.0 THEN
    	V3_ZANG := ACOS(A.Z / la);
    END_IF

    (* revision history
    hm	11 dec 2007	rev 1.0
    	original version

    hm	10. mar. 2009	rev 1.1
    	changed syntax of real constants to 0.0

    *)
END_FUNCTION