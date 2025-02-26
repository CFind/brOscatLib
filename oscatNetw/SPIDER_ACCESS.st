FUNCTION_BLOCK SPIDER_ACCESS
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=129*)
    CASE state OF

    00:
    	IF MODE > BYTE#0 AND MODE < BYTE#3 THEN
    		mode_save := MODE; (* Modus speichern *)
    		(* wenn kein '.' in Name dann ist es eine globale variable *)
    		IF FIND(VAR_NAME,'.') = 0 THEN
    			st_tmp := CONCAT('%40GV.',VAR_NAME);
    		ELSE
    			st_tmp := VAR_NAME;
    		END_IF

    		IF mode_save = BYTE#2 THEN (* 2 = Write *)
    			value_len := INT_TO_UINT(LEN(VALUE));
    			st_tmp := CONCAT(st_tmp,'+');
    			st_tmp := CONCAT(st_tmp,VALUE);
    			URL_DATA:=STRING_TO_URL(STR:= CONCAT('http://x/dir/cgi-bin/writeVal.exe?',st_tmp),DEFAULT_PROTOCOL:='',DEFAULT_PATH:='');
    		ELSE
    			URL_DATA:=STRING_TO_URL(STR:= CONCAT('http://x/dir/cgi-bin/readVal.exe?',st_tmp),DEFAULT_PROTOCOL:='',DEFAULT_PATH:='');
    		END_IF

    		state := 60;
    	END_IF
    60:
    	IF HTTP_GET.DONE THEN
    		IF mode_save = BYTE#2 THEN (* Write *)
    			body_len := HTTP_GET.BODY_STOP - HTTP_GET.BODY_START + BOOL_TO_UINT(HTTP_GET.BODY_STOP > UINT#0);
    			ERROR := BOOL_TO_DWORD(body_len <> value_len);
    		ELSE (* Read *)
    			IF HTTP_GET.BODY_START > 0 THEN
    				VALUE := BUFFER_TO_STRING(PT:=ADR(R_BUF.BUFFER),SIZE:=R_BUF.SIZE,START:=UINT_TO_INT(HTTP_GET.BODY_START),STOP:=UINT_TO_INT(HTTP_GET.BODY_STOP));
    			ELSE
    				VALUE := '';
    			END_IF
    		END_IF
    		state   := 100;

    	ELSIF (HTTP_GET.ERROR > DWORD#00) THEN
    		ERROR := HTTP_GET.ERROR;
    		state   := 100;
    	END_IF

    100:
    	(* UNLOCK HTTP DATA *)
    	IF HTTP_GET.DONE = FALSE THEN
    		state := 0;
    	END_IF

    END_CASE

    (* HTTP_GET *)
    HTTP_GET(	IP_C:=IP_C,
    			S_BUF:=S_BUF,
    			R_BUF:=R_BUF,
    			IP4:=DWORD#00,
    			GET:=state=60,
    			MODE:=BYTE#0,
    			UNLOCK_BUF:=state=100,
    			URL_DATA:=URL_DATA
    			);

    (* revision history
    ks	18. mar. 2009	rev 1.0
    	original version

    ks	12. apr. 2011	rev 1.1
    	fehlerkorrektur bei buffer_to_string
    *)
END_FUNCTION_BLOCK
