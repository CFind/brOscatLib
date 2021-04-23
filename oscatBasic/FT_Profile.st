FUNCTION_BLOCK FT_Profile
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=457*)
    (* read system time *)
    tx := DWORD_TO_TIME(T_PLC_MS());

    (* determine start condition *)
    IF E AND NOT edge THEN
    	RUN := TRUE;
    	ET := t#0s;
    	t0 := tx;
    	ta := tx;
    	tb := multime(time_1, M);
    	va := value_0;
    	vb := value_1;
    	temp := value_0;
    	state := 1;
    END_IF
    edge := E;

    (* generate startup profile *)
    IF run THEN
    	CASE state OF
    		1:	IF tx - ta >= tb THEN
    				ta := ta + tb;
    				tb := multime(time_2 - time_1, M);
    				va := value_1;
    				vb := value_2;
    				temp := value_1;
    				state := 2;
    			ELSE
    				temp := ((vb - va) * TIME_TO_REAL(tx - ta) / TIME_TO_REAL(tb) + va);
    			END_IF
    		2:	IF tx - ta >= tb THEN
    				ta := ta + tb;
    				tb := multime(time_3 - time_2, M);
    				va := value_2;
    				vb := value_3;
    				temp := value_2;
    				state := 3;
    			ELSE
    				temp := ((vb - va) * TIME_TO_REAL(tx - ta) / TIME_TO_REAL(tb) + va);
    			END_IF
    		3:	IF tx - ta >= tb THEN
    				ta := ta + tb;
    				tb := multime(time_10 - time_3, M);
    				va := value_3;
    				vb := value_10;
    				temp := value_3;
    				state := 4;
    			ELSE
    				temp := ((vb - va) * TIME_TO_REAL(tx - ta) / TIME_TO_REAL(tb) + va);
    			END_IF
    		4 :	IF tx - ta >= tb THEN
    				ta := ta + tb;
    				tb := multime(time_11 - time_10, M);
    				va := value_10;
    				vb := value_11;
    				temp := value_10;
    				IF E THEN state := 5; ELSE state := 6; END_IF
    			ELSE
    				temp := ((vb - va) * TIME_TO_REAL(tx - ta) / TIME_TO_REAL(tb) + va);
    			END_IF
    		5:	(* extend the signal while E is true *)
    			IF E THEN
    				ta := tx;
    			ELSE
    				state := 6;
    			END_IF
    		6:	IF tx - ta >= tb THEN
    				ta := ta + tb;
    				tb := multime(time_12 - time_11, M);
    				va := value_11;
    				vb := value_12;
    				temp := value_11;
    				state := 7;
    			ELSE
    				temp := ((vb - va) * TIME_TO_REAL(tx - ta) / TIME_TO_REAL(tb) + va);
    			END_IF
    		7:	IF tx - ta >= tb THEN
    				ta := ta + tb;
    				tb := multime(time_13 - time_12, M);
    				va := value_12;
    				vb := value_13;
    				temp := value_12;
    				state := 8;
    			ELSE
    				temp := ((vb - va) * TIME_TO_REAL(tx - ta) / TIME_TO_REAL(tb) + va);
    			END_IF
    		8:	IF tx - ta >= tb THEN
    				temp := value_13;
    				run := FALSE;
    			ELSE
    				temp := ((vb - va) * TIME_TO_REAL(tx - ta) / TIME_TO_REAL(tb) + va);
    			END_IF
    	END_CASE
    	Y := temp * K + O;
    	ET := tx - t0;
    END_IF

    (* revision history
    hm	27 feb 2007		rev 1.0
    	original version

    hm	15. sep2007		rev 1.1
    	replaced Time() with T_PLC_MS for compatibility and performance reasons

    *)
END_FUNCTION_BLOCK