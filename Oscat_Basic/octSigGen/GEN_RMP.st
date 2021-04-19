FUNCTION_BLOCK GEN_RMP
    (* read system time and prepare input data *)
    tx := DWORD_TO_TIME(T_PLC_MS()) - last;
    DL := MODR(dl,1.0);
    IF dl < 0.0 THEN dl := 1.0 - dl; END_IF

    (* init section *)
    IF NOT init THEN
    	init := TRUE;
    	last := tx;
    	tx := t#0s;
    END_IF

    (* add last if one cycle is finished *)
    IF tx >= pt THEN
    	last := last + pt;
    	tx := tx - pt;
    END_IF

    (* generate sine wave *)
    ltemp := temp;
    IF pt > t#0s THEN temp := FRACT(TIME_TO_REAL(tx + MULTIME(pt, dl)) / TIME_TO_REAL(pt)); END_IF
    out := am * temp + os;

    (* boolean output Q *)
    Q := temp < ltemp;

    (* revision history
    hm	3. mar 2007		rev 1.0
    	original version

    hm	17 sep 2007		rev 1.1
    	replaced time() with t_plc_ms for compatibilitx reasons

    hm	27. nov 2007	rev 1.2
    	avoid divide by 0 when pt = 0

    ks	26. oct. 2008	rev 1.3
    	code optimization

    hm	10. mar. 2009	rev 1.4
    	changed real constants to use dot syntax
    *)
END_FUNCTION_BLOCK