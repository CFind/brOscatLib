FUNCTION_BLOCK BLIND_SET
    (* read system time *)
    tx := DWORD_TO_TIME(OSCAT_BASIC.T_PLC_MS());

    (* check inputs *)
    IF IN THEN
    	IF override_manual OR (UP AND DN) THEN
    		status := 178;
    	END_IF
    END_IF

    (* state machine *)
    CASE STATUS OF
    	0: (* power on state *)
    		status := S_IN;

    	178: (* force values from PX and AX *)
    		PO := PX;
    		AO := AX;
    		QU := TRUE;
    		QD := TRUE;
    		(* check for end of forced position *)
    		IF NOT in THEN
    			STATUS := SEL(RESTORE_POSITION, S_IN, 179);
    			last := tx;
    		END_IF

    	179: (* restore previous position *)
    		PO := ps;
    		AO := as;
    		IF ((PO = PI) AND (AO = AI))  OR tx - last >= RESTORE_TIME THEN
    			status := S_IN;
    		END_IF

    ELSE
    	(* no operation transfer inputs to outputs *)
    	PO := PI;
    	ps := PI;
    	AO := AI;
    	as := AI;
    	STATUS := S_IN;
    	QU := UP;
    	QD := DN;
    END_CASE


    (* revision history
    hm	27. jul 2009	rev 1.0
    	original release

    *)
END_FUNCTION_BLOCK