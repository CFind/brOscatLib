FUNCTION_BLOCK NET_VAR_CONTROL
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=199*)
    IF X.ERROR_ID > BYTE#0 THEN (* Schwere Fehler bei Variablenzuordnung vorhanden  !! *)
    	X.STATE := BYTE#0;
    	ERROR := BYTE_TO_DWORD(X.ERROR_ID);
    	X.ERROR_ID := BYTE#0;
    	step := 999;
    END_IF

    CASE step OF

    00:	IF ACTIVATE AND NOT activate_last OR reset THEN

            (*  TCP + MASTER = C_MODE 0 (TCP + ACTIVE + PORT + IP) *)
            (*  UDP + MASTER = C_MODE 1 (UDP + ACTIVE + PORT + IP) *)
            (*  TCP + SLAVE  = C_MODE 2 (TCP + PASSIV + PORT + IP) *)
            (*  UDP + SLAVE  = C_MODE 3 (UDP + PASSIV + PORT + IP) *)
    	IF MASTER THEN
    		IP_C.C_MODE := BYTE#0;
    		step := 100;
    	ELSE
    		IP_C.C_MODE := BYTE#2;
    		step := 200;
    	END_IF
            IF UDP THEN IP_C.C_MODE := IP_C.C_MODE OR BYTE#1; END_IF
    	  	IP_C.C_PORT := REMOTE_PORT; (* Portnummer eintragen *)
    	  	IP_C.C_IP := REMOTE_IP4; (* IP eintragen *)
    	  	IP_C.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
    	  	IP_C.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
    	  	IP_C.R_OBSERVE := TRUE; (* Empfangsueberwachung *)
    		X.S_BUF.SIZE := UINT#0;
    		X.R_BUF.SIZE := UINT#0;
    		X.CYCLE := UDINT#0;
    		X.ERROR_ID := BYTE#0;
    		reset := FALSE;
    	END_IF

    (* ++++++++++++++++++++++++++++++++++++++++++++++ *)

    100:IF IP_C.C_STATE > BYTE#127 THEN (* Verbindung vorhanden *)
    		X.STATE := BYTE#1; (* Daten sammeln *)
    		X.BUF_SIZE := SIZEOF(X.S_BUF.BUFFER);
    		X.S_BUF.BUFFER[0] := UDINT_TO_BYTE(X.CYCLE);
    		X.INDEX := 1;
    		step := 110;
    	END_IF

    110:X.STATE := BYTE#0;
    	X.S_BUF.SIZE := INT_TO_UINT(X.INDEX); (* Datenlänge eintragen *)
    	step := 120;

    120:IF X.S_BUF.SIZE = UINT#0 AND X.R_BUF.SIZE >= UINT#1 THEN (* länge der empfangenen Daten prüfen *)
    		X.STATE := BYTE#2; (* Daten ausgeben *)
    		X.BUF_SIZE := X.R_BUF.SIZE;
    		X.INDEX := 1;
    		X.ERROR_ID := BYTE#0;
    		X.CYCLE := X.CYCLE + UDINT#1;
    		ERROR := DWORD#0; (* nach erfolgreichen Zyklus letzten Fehlercode löschen *)
    		RUN := TRUE;
    		step := 130;
    	END_IF

    130:X.STATE := BYTE#0;
    	X.R_BUF.SIZE := UINT#0;
    	IF NOT ACTIVATE THEN
    		step := 999; (* Beenden *)
    	ELSIF tscan.Q THEN
    		step := 100;
    	END_IF

    (* ++++++++++++++++++++++++++++++++++++++++++++++ *)

    200:IF X.R_BUF.SIZE >= UINT#1 THEN
    		X.STATE := BYTE#2; (* Daten ausgeben *)
    		X.BUF_SIZE := X.R_BUF.SIZE;
    		X.INDEX := 1;
    		step := 210;
    	END_IF

    210:X.STATE := BYTE#1; (* Daten sammeln *)
    	X.BUF_SIZE := SIZEOF(X.R_BUF.BUFFER);;
    	X.S_BUF.BUFFER[0] := X.R_BUF.BUFFER[0]; (* Cycle übernehmen *)
    	X.INDEX := 1;
    	X.R_BUF.SIZE := UINT#0;
    	step := 220;

    220:X.STATE := BYTE#0;
    	X.S_BUF.SIZE := INT_TO_UINT(X.INDEX); (* Datenlänge eintragen *)
    	step := 230;

    230:IF X.S_BUF.SIZE = UINT#0 THEN
    		ERROR := DWORD#0; (* nach erfolgreichen Zyklus letzten Fehlercode löschen *)
    		RUN := TRUE;
    		IF NOT ACTIVATE THEN
    			step := 999; (* Beenden *)
    		ELSE
    			step := 200;
    		END_IF
    	END_IF

    999:IP_C.C_ENABLE := FALSE; (* Beenden *)
    	RUN := FALSE;
    	step := 0;

    END_CASE

    (* ++++++++++++++++++++++++++++++++++++++++++++++ *)

    IPC(IP:= DWORD#0, PORT:= WORD#0 , TIME_OUT:= WATCHDOG, IP_C:= IP_C, S_BUF:= X.S_BUF, R_BUF:= X.R_BUF);

    IF IP_C.ERROR > DWORD#0 THEN
    	ERROR := IP_C.ERROR;
    	RUN := FALSE;
    	reset := TRUE;
    	step := 0;
    END_IF

    activate_last := ACTIVATE; (* letzten Status sichern zur Flankenerkennung *)
    tscan(IN:= step <> 110 ,PT:=SCAN_TIME);

    (* revision history
    ks	15.may. 2011	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
