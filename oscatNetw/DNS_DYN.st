FUNCTION_BLOCK DNS_DYN
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=92*)
    CASE state OF

    00:	IF ENABLE AND ((UPDATE AND NOT update_last) OR w.Q) THEN
    		state := 20;
    		DONE := FALSE;
    		BUSY := TRUE;
    		ERROR_C := DWORD#0;
    		ERROR_T := BYTE#0;

    		IF MODE = 0 THEN (* dyndns.org *)
    			s2 := CONCAT('http://members.dyndns.org/nic/UPDATE?HOSTNAME=',HOSTNAME);
    		ELSE (* selfhost.de *)
    			s2 := 'http://carol.selfhost.de/nic/UPDATE?HOSTNAME=1';
    		END_IF
    		IF IP4 > 0 THEN (* parametrierte IP verwenden *)
    			s1 := CONCAT('&myip=',IP4_TO_STRING(IP4));
    			s2 := CONCAT(s2,s1);
    		END_IF
    		URL_DATA:=STRING_TO_URL(STR:=s2, DEFAULT_PROTOCOL:='', DEFAULT_PATH:=''); (* URL for DNS UND HTTP-GET *)
    		s1 := CONCAT(USERNAME,':');
    		s1 := CONCAT(s1,PASSWORD); (* BASE64 Encode Text *)
    	END_IF

    20:	IF DNS_CLIENT.DONE THEN (* DNS_CLIENT *)
    			state := 40;
    	ELSIF (DNS_CLIENT.ERROR > DWORD#00) THEN (* Fehlerbehandlung *)
    		ERROR_C := DNS_CLIENT.ERROR;
    		ERROR_T := BYTE#01;
    		BUSY := FALSE;
    		state := 0;
    	END_IF

    40: IF base64_done THEN (* BASE64 Encode beendet ? *)
    		s1 := CONCAT('Authorization: Basic ',s2);
    		s1 := CONCAT(s1,'$0D$0AUser-Agent: x$0D$0A');
    		URL_DATA.HEADER := s1;
    		state := 60;
    	END_IF

    60:	IF HTTP_GET.DONE THEN
    		state := 0;
    		BUSY := FALSE;
    		DONE := TRUE;

    		(* !! Codes !!
    		Successful Updates: 		good , nchg
    		UPDATE Syntax Errors:		badsys , badagent
    		Account-Related Errors:		badauth , !donator
    		HOSTNAME-Related Errors:	notfqdn , nohost , !yours , numhost , abuse
    		Server Error Conditions:	dnserr , 911
    		*)
    		s2 := BUFFER_TO_STRING(PT:=ADR(R_BUF.BUFFER),SIZE:=SIZEOF(R_BUF.BUFFER),START:=HTTP_GET.BODY_START + 3,STOP:=HTTP_GET.BODY_STOP - 7);
    		IF FIND(s2,'good') = 0 THEN
    			IF FIND(s2,'nochg') = 0 THEN
    				ERROR_C := DWORD#1;
    				ERROR_T := BYTE#03;
    				DONE := FALSE;
    			END_IF
    		END_IF
    	ELSIF (HTTP_GET.ERROR > DWORD#00) THEN (* Fehlerbehandlung *)
    		ERROR_C := HTTP_GET.ERROR;
    		ERROR_T := BYTE#02;
    		BUSY := FALSE;
    		state := 0;
    	END_IF

    END_CASE

    DNS_CLIENT(IP_C:=IP_C,	S_BUF:=S_BUF, R_BUF:=R_BUF,DOMAIN:=URL_DATA.DOMAIN, IP4_DNS:=0, ACTIVATE:=state=20); (* DNS_CLIENT *)
    HTTP_GET( IP_C:=IP_C, S_BUF:=S_BUF, R_BUF:=R_BUF, IP4:=DNS_CLIENT.IP4, GET:=state=60, MODE:=2, UNLOCK_BUF:=state<>60,URL_DATA:=URL_DATA); (* HTTP_GET *)
    BASE64_ENCODE_STR( RUN:=state=40, STR1:=s1, STR2:=s2, DONE=>base64_done); (* BASE64 Encode *)

    IF T_UPDATE > T#0ms THEN w(IN:=state=0, PT:=T_UPDATE); END_IF
    update_last := UPDATE;

    (* revision history
    ks	01. jan. 2010	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
