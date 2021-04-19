FUNCTION_BLOCK DIMM_2
    (* debouncing for inputs i1 and i2 *)
    t1(IN := I1, PT := T_DEBOUNCE);
    t2(IN := I2, PT := T_DEBOUNCE);
    dc1(in := t1.Q, T_LONG := T_DIMM_START);
    dc2(in := t2.Q, T_LONG := T_DIMM_START);


    IF RST THEN
    	IF RST_OUT THEN out := 0; END_IF
    	Q := FALSE;
    	D1 := FALSE;
    	D2 := FALSE;
    ELSIF set THEN
    	OUT := VAL;
    	Q := TRUE;
    ELSIF dc1.SINGLE THEN
    	(* single click on i1 turns the dimmer on *)
    	out := LIMIT(MAX(MIN_ON,1), out, MAX_ON);
    	Q := TRUE;
    ELSIF dc2.SINGLE THEN
    	(* single click on i2 turns the dimmer off *)
    	Q := FALSE;
    ELSIF dc1.TP_LONG THEN
    	(* continuous on at i1 dimms up *)
    	IF NOT Q THEN
    		out := SEL(SOFT_DIMM, LIMIT(MAX(MIN_ON,1), out, MAX_ON), 1);
    	END_IF
    	Q := TRUE;
    	dim.DIR := TRUE;
    ELSIF dc2.TP_LONG THEN
    	(* continuous on at i2 dimms down *)
    	dim.DIR := FALSE;
    END_IF

    (* set the double click output *)
    IF NOT DBL1_TOG THEN D1 := FALSE; END_IF
    IF dc1.DOUBLE THEN
    	IF DBL1_SET THEN
    		OUT := DBL1_POS;
    		Q := TRUE;
    	ELSE
    		D1 := NOT D1;
    	END_IF
    END_IF
    IF NOT DBL2_TOG THEN D2 := FALSE; END_IF
    IF dc2.DOUBLE THEN
    	IF DBL2_SET THEN
    		OUT := DBL2_POS;
    		Q := TRUE;
    	ELSE
    		D2 := NOT D2;
    	END_IF
    END_IF


    (* while dimming is active ramp the output out up or down *)
    dim(dir := dc2.LONG, e := dc1.LONG OR dc2.LONG , TR := T_DIMM, rmp := out);

    (* turn off output if a value of 0 is reached *)
    IF out = 0 THEN Q := FALSE; END_IF

    (* limit the maximum runtime *)
    IF t_ON_MAX > t#0s THEN
    	t3(in := q, pt := T_ON_MAX);
    	Q := Q XOR t3.Q;
    END_IF




    (* revision history

    hm 22. mar. 2009	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK