FUNCTION_BLOCK FILTER_DW
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=277*)
    (* read system time *)
    tx := T_PLC_MS();

    (* startup initialisation *)
    IF NOT init OR T = t#0s THEN
    	init := TRUE;
    	Yi := DWORD_TO_REAL(X);
    ELSE
    	Yi := Yi + (DWORD_TO_REAL(X) - DWORD_TO_REAL(Y)) * DWORD_TO_REAL(tx - last) / TIME_TO_REAL(T);
    END_IF
    last := tx;

    Y := REAL_TO_DWORD(Yi);



    (*
    hm 10. oct. 2008	rev 1.0
    	original version

    hm	3. nov. 2008	REV 1.1
    	corrected an overflow problem
    *)
END_FUNCTION_BLOCK