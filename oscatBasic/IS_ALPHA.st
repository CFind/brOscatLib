FUNCTION IS_ALPHA
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=165*)
    pt ACCESS ADR(STR);
    L := LEN(STR);
    FOR pos := 1 TO L DO
    	IF NOT ISC_ALPHA(pt) THEN
    		IS_ALPHA := FALSE;
    		RETURN;
    	END_IF
        pt ACCESS (ADR(pt) + 1);
    END_FOR
    IS_ALPHA := L > 0;


    (* revision history
    hm	29. feb 2008	rev 1.0
    	original version

    hm	29. mar. 2008	rev 1.1
    	changed STRING to STRING(STRING_LENGTH)
    *)
END_FUNCTION
