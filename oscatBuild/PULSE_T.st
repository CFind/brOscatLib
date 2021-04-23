FUNCTION_BLOCK PULSE_T
    (*http://www.oscat.de/images/OSCATBuilding/oscat_building100_en.pdf#page=56*)
    tx := DWORD_TO_TIME(OSCAT_BASIC.T_PLC_MS());
    IF NOT init THEN
    	init := TRUE;
    	last := tx;
    ELSIF RST THEN
    	(* asynchronous reset *)
    	Q := FALSE;
    ELSIF IN AND NOT edge AND NOT Q THEN
    	(* a rising edge on in will reversre the output status, if new pulse is startet the start time is stored in last *)
    	last := tx;
    	Q := TRUE;
    ELSIF NOT IN AND edge AND ((tx - last) > T1) THEN
    	(* a falling edge on IN will clear the output if in was high for more then T1 *)
    	Q := FALSE;
    ELSIF (tx - last) >= T2 THEN
    	(* timeout for long pulse if second click did not occur or in stays high *)
    	Q := FALSE;
    END_IF

    edge := IN;

    (* revision histroy
    hm	15. jul. 2008	rev 1.0
    	original release


    *)	

END_FUNCTION_BLOCK