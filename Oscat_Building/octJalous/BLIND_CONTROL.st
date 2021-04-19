FUNCTION_BLOCK BLIND_CONTROL
    IF bTimeTest THEN
    	PI:=iPos;
    	AI:=iAngel;
    	UP:=TRUE;
    	DN:=TRUE;
    END_IF

    (* Check Position*)
    act(T_UD:=T_UD, T_ANGLE:=T_ANGLE, T_lockout := T_Lockout);

    IF UP AND DN THEN
    	(* automatic modus detected *)
    	(* first find correct position *)
    	IF BYTE_TO_INT(act.pos) < BYTE_TO_INT(pi) - delta THEN
    		act.UP := TRUE;
    		act.DN := FALSE;
    		delta := 0;
    		STATUS := 121;
    	ELSIF BYTE_TO_INT(act.pos) > BYTE_TO_INT(pi) + delta THEN
    		act.UP := FALSE;
    		act.DN := TRUE;
    		delta := 0;
    		STATUS := 122;
    	(* regulate angle *)
    	ELSIF BYTE_TO_INT(act.ang) < BYTE_TO_INT(ai) - delta AND T_angle > T#100ms THEN
    		act.UP := TRUE;
    		act.DN := FALSE;
    		delta := sens/2;
    		STATUS := 123;
    	ELSIF BYTE_TO_INT(act.ang) > BYTE_TO_INT(ai) + delta AND T_angle > T#100ms THEN
    		act.UP := FALSE;
    		act.DN := TRUE;
    		delta := sens/2;
    		STATUS := 124;
    	(* correct position reached *)
    	ELSE
    		act.UP := FALSE;
    		act.DN := FALSE;
    		delta := sens;
    		STATUS := S_IN;
    	END_IF
    ELSE
    	act.UP := UP;
    	act.DN := DN;
    	STATUS := S_IN;
    END_IF

    (* blind control calls blind_actuator *)
    act(T_UD:=T_UD, T_ANGLE:=T_ANGLE, T_lockout := T_Lockout);
    pos := act.pos;
    ang := act.ang;
    MU := act.QU;
    md := act.QD;
    status := act.status;

    (* revision history
    hm	29. sep 2007	rev 1.0
    	original release

    hm	6. oct 2007	rev 1.1
    	rearranged outputs
    	integrated blind_actuator into blind_control

    hm	16. oct 2007	rev 1.2
    	ignore angle when t_angle = 0

    hm 29. oct 2007	rev 1.3
    	added lockout configuration time for motor direction change
    	sens has a setup value of 5

    hm	27. jul. 2009	rev 1.4
    	changed status handling

    ae	08. mar. 2010	rev 1.5
    	at aPosition bevor control
    	at tolerance "delta := sens/2;"

    *)
END_FUNCTION_BLOCK