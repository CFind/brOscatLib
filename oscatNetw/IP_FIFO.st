FUNCTION_BLOCK IP_FIFO
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=108*)
    IF NOT FIFO.INIT THEN
    	FIFO.INIT := TRUE;
    	FIFO.NW := 1;
    	FIFO.NR := 1;
    	FIFO.EMPTY := TRUE;
    	FIFO.FULL := FALSE;
    	FIFO.TOP := 128; (* Arraygroesse 1 bis x *)
    	FIFO.MAX_ID := BYTE#1; (* maximale anzahl von Anmeldungen einer ID *)
    END_IF

    (* wenn keine ID vorhanden dann die naechste freie ID zuteilen *)
    IF ID = BYTE#00 THEN
    	IF FIFO.ID < INT_TO_BYTE(FIFO.TOP) THEN
    		ID := USINT_TO_BYTE(BYTE_TO_USINT(FIFO.ID) + USINT#1); (* ID +1 *)
    		FIFO.ID := ID; (* ID eintragen *)
    	    	(*####################  DEBUG-MESSAGE  ###################################*)
    	    	(*IF _debug_enable THEN
    	      		LOG_CL.NEW_MSG := 'FIFO: NEW ID:~1';
    	      		LOG_CL.PRINTF[1]  := BYTE_TO_STRING(ID);
    	      		LOG_MSG();
    	    	END_IF*)
    	    	(*########################################################################*)
    	ELSIF STATE < BYTE#200 THEN
    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'FIFO: OVERFLOW ADD ID';
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)

    		(* sollte nie passieren ! -> es sind zuviele teilnehmer angemeldet *)
    		(* es wird keine Nummer vergeben und alle anfragen werden negativ beantwortet *)
    		STATE := BYTE#255;
    		RETURN;
    	END_IF
    END_IF

    IF STATE = BYTE#1 AND NOT FIFO.FULL THEN (* Anmelden *)
    	(* nur eintragen wenn maximale anzahl nicht ueberschritten wurde *)
    	tmp := BYTE_TO_INT(ID);
    	IF FIFO.Y[tmp] < FIFO.MAX_ID THEN
    		FIFO.Y[tmp] := USINT_TO_BYTE(BYTE_TO_USINT(FIFO.Y[tmp]) + USINT#1); (* IP_ID Zähler +1 *)
    		tmp := FIFO.NW; (* geht bei mir leider nicht anders *)
    		FIFO.X[tmp] := ID;
    		IF FIFO.NW = FIFO.TOP THEN FIFO.NW := 1; ELSE FIFO.NW := FIFO.NW + 1; END_IF
    		FIFO.FULL := FIFO.NW = FIFO.NR;
    		FIFO.EMPTY := FALSE;
    		STATE := BYTE#2; (* weiterschalten auf "Warten auf Freigabe" *)
    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'FIFO: ADD ID:~1';
    			LOG_CL.PRINTF[1]  := BYTE_TO_STRING(ID);
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)

    	END_IF
    END_IF

    IF STATE = BYTE#2 AND NOT FIFO.EMPTY THEN (* check current stack element *)
    	tmp := FIFO.NR; (* geht bei mir leider nicht anders *)
    	IF ID = FIFO.X[tmp] THEN
    	STATE := BYTE#3; (* weiterschalten auf "Zugriffsfreigabe" *)
    	END_IF
    END_IF

    IF STATE = BYTE#4 AND NOT FIFO.EMPTY THEN (* remove from stack *)
    	tmp := FIFO.NR; (* geht bei mir leider nicht anders *)
    	IF ID = FIFO.X[tmp] THEN
    		tmp := BYTE_TO_INT(ID); (* geht bei mir leider nicht anders *)
    		FIFO.Y[tmp] := USINT_TO_BYTE(BYTE_TO_USINT(FIFO.Y[tmp]) - USINT#1); (* ID Zähler -1 *)
    		IF FIFO.NR = FIFO.TOP THEN FIFO.NR := 1; ELSE FIFO.NR := FIFO.NR + 1; END_IF
    		FIFO.EMPTY := FIFO.NR = FIFO.NW;
    		FIFO.FULL := FALSE;
    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'FIFO: REMOVE ID:~1';
    			LOG_CL.PRINTF[1]  := BYTE_TO_STRING(ID);
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)
    	END_IF
    	STATE := BYTE#5; (* "Remove done" *)
    END_IF

    (* revision history
    ks	18. oct. 2008	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
