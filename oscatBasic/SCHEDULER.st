FUNCTION_BLOCK SCHEDULER
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=198*)
    (* read system_time *)
    tx := UDINT_TO_TIME(T_PLC_MS());

    IF NOT init THEN
    	init := TRUE;
    	s0 := tx - T0;
    	s1 := tx - T1;
    	s2 := tx - T2;
    	s3 := tx - T3;
    END_IF

    Q0 := FALSE;
    Q1 := FALSE;
    Q2 := FALSE;
    Q3 :=FALSE;

    CASE c OF
    	0: 	IF tx - s0 >= T0 THEN
    			Q0 := E0;
    			s0 := tx;
    		END_IF
    		c := 1;
    	1: 	IF tx - s1 >= T1 THEN
    			Q1 := E1;
    			s1 := tx;
    		END_IF
    		c := 2;
    	2: 	IF tx - s2 >= T2 THEN
    			Q2 := E2;
    			s2 := tx;
    		END_IF
    		c := 3;
    	3: 	IF tx - s3 >= T3 THEN
    			Q3 := E3;
    			s3 := tx;
    		END_IF
    		c := 0;
    END_CASE


    (* revision history

    hm 28. sep. 2008	rev 1.0
    	original version

    hm	14. mar. 2009	rev 1.1
    	removed double assignments

    *)
END_FUNCTION_BLOCK
