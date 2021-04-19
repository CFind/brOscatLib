FUNCTION_BLOCK CYCLE_TIME
    tx := DWORD_TO_TIME(T_PLC_MS()) - last_cycle;
    IF rst THEN
    	ct_min := t#10h;
    	ct_max := t#0ms;
    	cycles := 0;
    ELSIF last_cycle > t#0s THEN
    	IF tx < ct_min THEN ct_min := tx;
    	ELSIF tx > ct_max THEN ct_max := tx;
    	END_IF
    	ct_last := tx;
    ELSIF ct_min = t#0s THEN
    	ct_min := t#0s - t#1ms;
    END_IF
    IF init THEN
    	systime := systime + tx;
    		IF systime >= t#1d THEN
    			systime := systime - t#1d;
    			sysdays := sysdays + 1;
    		END_IF
    END_IF
    init := TRUE;
    last_cycle := last_cycle + tx;
    cycles := cycles + 1;

    (*	revision history
    hm 12.12.2006		rev 1.1
    	added cycles output, a dword cycle counter.
    hm 10.3.2007			rev 1.2
    	changed initialization of ct_min to t#10h for compatibility with siemens s7

    hm	16.9.2007		rev 1.2
    	changed Time() in T_PLC_MS() for compatibility resons

    *)
END_FUNCTION_BLOCK