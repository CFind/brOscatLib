FUNCTION_BLOCK FT_RMP
    (* read system time *)
    tx := DWORD_TO_TIME(T_PLC_MS()) - last;

    IF NOT init THEN
    	init := TRUE;
    	last := tx;
    	tx := t#0s;
    	out := in;
    END_IF
    IF NOT rmp THEN
    	out := in;
    	busy := FALSE;
    ELSIF out > in THEN
    	(* ramp down *)
    	out := out - TIME_TO_REAL(tx) * 0.001 * KF;
    	out := MAX(in, out);
    ELSIF out < in THEN
    	(* ramp up *)
    	out := out + TIME_TO_REAL(tx) * 0.001 * KR;
    	out := MIN(in, out);
    END_IF

    (* set busy and dir flags *)
    IF out < in THEN
    	busy := TRUE;
    	ud := TRUE;
    ELSIF out > in THEN
    	busy := TRUE;
    	ud := FALSE;
    ELSE
    	busy := FALSE;
    END_IF
    last := last + tx;


    (* revision history:

    hm 8.10.2006			rev 1.1
    	added ud output

    hm 12. feb 2007		rev 1.2
    	added init variable and corrected a possible startup problem

    hm	17. sep 2007	rev 1.3
    	replaced time() with t_plc_ms() for compatibility reasons

    hm	25. jan 2008	rev 1.4
    	performance improvements
    	allow KR and KF to be 0
    *)
END_FUNCTION_BLOCK