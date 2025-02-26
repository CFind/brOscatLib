FUNCTION_BLOCK DNS_REV_CLIENT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=90*)
    (* DOMAIN Name System (query) *)

    CASE state OF
    00: (* auf positive Flanke GET warten *)
    	IF ACTIVATE AND NOT activate_last THEN
    		ERROR := DWORD#0;
    		ip4_copy := IP4; (* IP4 sichern *)
    		ip_state := BYTE#1;
    		DOMAIN := '';
    		DONE := FALSE;

    		d := '';
    		FOR i := 1 TO 4 DO
    			d := CONCAT(d,BYTE_TO_STRING(DWORD_TO_BYTE(IP4)));
    			d := CONCAT(d,'.');
    			IP4 := ROR(IP4,8);
    		END_FOR
    		d := CONCAT(d,'in-addr.arpa');
    		state := 10;
    	END_IF

    10: (* Bei IP_Control anmelden *)
    	IF ip_state = BYTE#3 THEN
    		dl := LEN(d);

    		(* sendebuffer initialisieren *)
    		char_count := 17 + dl;
    		FOR i := 0 TO char_count DO
    			S_BUF.BUFFER[i] := BYTE#00;
    		END_FOR

    		tid := UINT_TO_BYTE(BYTE_TO_UINT(tid) + UINT#1);
    		S_BUF.BUFFER[01] := tid; (* Transaction ID lowbyte *)
    		S_BUF.BUFFER[02] := BYTE#16#01; (* Flags: highbyte *)
    		S_BUF.BUFFER[05] := BYTE#16#01; (* Questions: lowbyte *)

    		(* den servernamen von hinten nach vorne bearbeiten *)
    		i := dl + 12;
    		char_count := 0;

    		WHILE i > 12 DO
    			char := CODE(STR:=d,POS:=i - 12);

    			(* prüfe auf haupt/sub domänen namens-teiler "." *)
    			IF char = BYTE#46 THEN
    				(* anstelle des teilers "." wird die länge des erkannten haupt/sub domänennames eingetragen *)
    				S_BUF.BUFFER[i] := INT_TO_BYTE(char_count);
    				char_count := 0;
    			ELSE
    				S_BUF.BUFFER[i] := char; (* char in buffer eintragen *)
    				char_count := char_count + 1; (* anzahl char zählen *)
    			END_IF
    			i := i - 1;
    		END_WHILE

    		S_BUF.BUFFER[i] := INT_TO_BYTE(char_count); (* längenangabe des ganz linken (ersten) domänennamens eintragen *)
    		i := dl + 15; (* position hinter dem servernamen *)
    		S_BUF.BUFFER[i] := BYTE#12; (* Type: PTR (DOMAIN name pointer) lowbyte *)
    		i := i + 2;
    		S_BUF.BUFFER[i] := BYTE#01; (* Class: IN lowbyte *)
    		i := i + 1;

    		(* IP Datenverkehr einrichten *)
    		IP_C.C_PORT := WORD#53; (* Portnummer eintragen *)
    		IP_C.C_IP := IP4_DNS; (* IP eintragen *)
    		IP_C.C_MODE := BYTE#1; (* Mode: UDP+AKTIV+PORT+IP *)
    		IP_C.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
    		IP_C.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
    		IP_C.R_OBSERVE  := TRUE; (* Datenempfang ueberwachen *)
    		S_BUF.SIZE := INT_TO_UINT(i); (* sendelänge eintragen *)
    		R_BUF.SIZE := UINT#0; (* Empfangslänge rücksetzen *)
    		state := 30;
    	END_IF

    30:
    	IF IP_C.ERROR <> DWORD#00 THEN
    		ERROR := IP_C.ERROR;
    	(* prüfe ob antwort telegramm die richtige Transaction-ID und mindestlänge hat *)
    	ELSIF (S_BUF.SIZE = UINT#0) AND (tid = R_BUF.BUFFER[1]) AND (R_BUF.SIZE >= INT_TO_UINT(i+12)) THEN

    		(* prüfe Return code der Flags. 4 bits *)
    		ERROR := BYTE_TO_DWORD(R_BUF.BUFFER[3] AND BYTE#2#0000_1111);

    		IF ERROR = DWORD#00 THEN

    			i := R_BUF.SIZE - 2;
    			WHILE R_BUF.BUFFER[i] > 0 DO
    				IF i = 0 THEN EXIT; END_IF
    				i := i - 1;
    			END_WHILE

    			i := i + 2;
    			p1 := i + 1;
    			WHILE i < R_BUF.SIZE DO
    				dl := R_BUF.BUFFER[i];
    				IF dl > 0 THEN
    					R_BUF.BUFFER[i] := BYTE#46;
    					i := i + dl + 1;
    				ELSE
    					DOMAIN := BUFFER_TO_STRING(PT:=ADR(R_BUF.BUFFER),SIZE:=SIZEOF(R_BUF.BUFFER),START:=p1,STOP:=i-1);
    					EXIT;
    				END_IF
    			END_WHILE
    			state := 0;
    			DONE := TRUE;
    		END_IF
    	END_IF

    	IF ERROR <> DWORD#0 THEN
    		state := 0;
    	END_IF

    	IF state = 0 THEN
    		IP_C.R_OBSERVE := FALSE; (* Datenempfang ueberwachen *)
    		ip_state := BYTE#4; (* Abmelden *)
    	END_IF

    END_CASE

    activate_last := ACTIVATE; (* letzten Status sichern zur Flankenerkennung *)

    (* IP_FIFO *)
    IP_FIFO(FIFO:=IP_C.FIFO,state:=ip_state,ID:=ip_id);

    (* revision history

    ks	28. dec. 2009	rev 1.0
    	original version

    *)


    (*----------------------------------------------------------------------------------------------------------------*)
    (* Flags: 0x0100 (Standard query)                                                                                            *)
    (* 0... .... .... .... = Response: Message is a query                                                                   *)
    (* .000 0... ....  = Opcode: Standard query (0)                                                                          *)
    (* .... ..0. .... .... = Truncated: Message is not truncated                                                          *)
    (* .... ...1 .... .... = Recursion desired: Do query recursively                                                    *)
    (* .... .... .0.. .... = Z: reserved (0)                                                                                                  *)
    (* .... .... ...0 .... = Non-authenticated data OK: Non-authenticated data is unacceptable *)
    (*-----------------------------------------------------------------------------------------------------------------*)

    (*
    Errorcodes  Description	References 
    000	No ERROR. 		 	The request completed successfully.
    001	Format ERROR. 		The name server was unable to interpret the query. 
    002	Server failure.  	The name server was unable to process this query due to a problem with the name server. 
    003	Name ERROR. 	 	Meaningful only for responses from an authoritative name server, this code signifies that the DOMAIN name referenced in the query does not exist.
    004	Not Implemented. 	The name server does not support the requested kind of query.
    005	Refused. 			The name server refuses to perform the specified operation for policy reasons.
      						 For example, a name server may not wish to provide the information to the particular requester, or a name server may not wish to perform a particular operation (e.g., zone transfer) for particular data.
    006	YXDomain.			Name Exists when it should not. 
    007	YXRRSet. RR			Set Exists when it should not. 
    008	NXRRSet. RR			Set that should exist does not. 
    009	NotAuth.			Server Not Authoritative for zone. 
    010	NotZone,			Name not contained in zone. 
    255	Timeout				No Response  
    *)   
END_FUNCTION_BLOCK
