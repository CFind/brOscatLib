FUNCTION_BLOCK IRTRANS_SND_8
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=44*)
    d := IP_C.C_STATE > 127 AND (IP_C.MAILBOX[1] > 0 OR IP_C.C_MODE <> 5);
    IF NOT d THEN RETURN; END_IF

    t(IN:= lk = k , PT:=T_REPEAT);

    IF S_BUF.size = 0 THEN
    	IF IN_0 THEN
    		skey := KEY_CODE_0; k := 1;
    	ELSIF IN_1 THEN
    		skey := KEY_CODE_1; k := 2;
    	ELSIF IN_2 THEN
    		skey := KEY_CODE_2; k := 3;
    	ELSIF IN_3 THEN
    		skey := KEY_CODE_3; k := 4;
    	ELSIF IN_4 THEN
    		skey := KEY_CODE_4; k := 5;
    	ELSIF IN_5 THEN
    		skey := KEY_CODE_5; k := 6;
    	ELSIF IN_6 THEN
    		skey := KEY_CODE_6; k := 7;
    	ELSIF IN_7 THEN
    		skey := KEY_CODE_7; k := 8;
    	ELSE
    		lk := 0;
    		KEY := 0;
    		RETURN; (* beenden wenn kein KEY aktiv *)
    	END_IF

    	IF lk <> k OR t.Q THEN (* anderer KEY oder repeat wartezeit abgelaufen *)
    		str := CONCAT('snd ',DEV_CODE);
    		str := CONCAT(str,',');
    		str := CONCAT(str,skey);
    		size := LEN(str);
    		_STRING_TO_BUFFER(str:=str, POS:=0, PT:=ADR(S_BUF.BUFFER), size:=size);
    		S_BUF.size := size; (* Sendelänge eintragen *)
    		KEY := k;
    		lk := k; (* letzten KEY speichern *)
    		t(IN:=FALSE); (* Reset Time *)
    	END_IF
    END_IF

    (* revision history
    hm	6. dec 2009		rev 1.0
    	original version
    *)
END_FUNCTION_BLOCK
