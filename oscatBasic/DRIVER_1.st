FUNCTION_BLOCK DRIVER_1
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=454*)
    IF off.Q THEN Q := FALSE; END_IF
    IF rst THEN
    	Q := FALSE;
    ELSIF set THEN
    	Q := TRUE;
    ELSIF IN AND NOT edge THEN
    	IF toggle_mode THEN q := NOT Q; ELSE q := TRUE; END_IF
    END_IF
    edge := in;
    IF timeout > t#0s THEN off(in := Q, PT := Timeout); END_IF


    (* revision history
    hm	2. jan 2008		rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK