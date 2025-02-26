FUNCTION_BLOCK SMTP_CLIENT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=123*)
    CASE step OF

    00:
    	IF ACTIVATE AND NOT activate_last THEN
    		TIMEOUT := MAX(T#10s,TIMEOUT);
    		timeout2 := TIMEOUT + T#1s;
    		timeout3 := TIMEOUT / 2;
    		DONE := FALSE;
    		ip_c_red_disable := FALSE;
    		ERROR_C := DWORD#0;
    		ERROR_T := BYTE#0;
    		FSD.ERROR := BYTE#0;
    		file_delete := FALSE;
    		URL_DATA := STRING_TO_URL(STR:=SERVER,DEFAULT_PROTOCOL:='',DEFAULT_PATH:='/');
    		idx1 := FIND(URL_DATA.USER,'%'); (* % Zeichen auf @ ändern *)
    		IF idx1 > 0 THEN
    			URL_DATA.USER := REPLACE(URL_DATA.USER,'@',1,idx1);
    		END_IF
    		esmtp := LEN(URL_DATA.PASSWORD) > 0; (* SMTP oder ExtendedSMTP *)
    		step := 10;
    	END_IF

    10:
    	IF DNS_CLIENT.DONE THEN
    		step := 20;
    	ELSIF DNS_CLIENT.ERROR <> DWORD#0 THEN
    		ERROR_C := DNS_CLIENT.ERROR;
    		ERROR_T := BYTE#1;
    		step := 980;
    	END_IF

    20:	(* SMTP Kommunikation einrichten *)
    	IF FIND(';SSL;ssl;Ssl', URL_DATA.PROTOCOL) > 1 THEN
    		ssl_mode := BYTE#1;
    		IP_C.C_PORT := SEL(URL_DATA.PORT = WORD#0,URL_DATA.PORT,WORD#465); (* Portnummer eintragen *)
    		IP_C.MAILBOX[16] := BYTE#1; (* SSL Mode freigeben *)
    	ELSIF FIND(';TLS;tls;Tls', URL_DATA.PROTOCOL) > 1 THEN
    		ssl_mode := BYTE#2;
    		IP_C.C_PORT := SEL(URL_DATA.PORT = WORD#0,URL_DATA.PORT,WORD#587); (* Portnummer eintragen *)
    		IP_C.MAILBOX[16] := BYTE#0; (* noch kein SSL Mode*)
    	ELSE
    		ssl_mode := BYTE#0;
    		IP_C.C_PORT := SEL(URL_DATA.PORT = WORD#0,URL_DATA.PORT,WORD#25); (* Portnummer eintragen *)
    		IP_C.MAILBOX[16] := BYTE#0; (* kein SSL Mode*)
    	END_IF

      	IP_C.C_IP := DNS_CLIENT.IP4; (* IP eintragen *)
      	IP_C.C_MODE := BYTE#0; (* Mode: TCP+ACTIV+PORT *)
      	IP_C.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
      	IP_C.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
      	IP_C.R_OBSERVE := TRUE; (* Empfangsueberwachung *)
    	IP_C.MAILBOX[3] := BYTE#0; (* IP Empfang wieder freigeben *)
    	R_BUF.SIZE := UINT#0;
    	snd_enable := TRUE; (* sofortiges senden erlauben *)
    	snd_idx := 0;
    	step := 30;

    30:	
    	IF rcv_state = 220 THEN (* 220 = Service ready *)
    		IF esmtp THEN
    			snd_text := 'EHLO OSCAT'; (* ExtendedSMTP *)

    			str1:= SEL(ssl_mode = BYTE#2,auth_names,auth_names_tls);
    			auth_state := BYTE#0;
    			idx2 := 1900;

    			next_step := 40;
    		ELSE
    			snd_text := 'HELO OSCAT'; (* SMTP *)
    			next_step := 90;
    		END_IF
    		snd_lf_cnt := 1;
    	END_IF

    40:	
    	IF rcv_state = 250 THEN
    		(* 250 = Requested mail action okay, complete
    			1. bei manchen Providern wird bei SSL kein AUTH verfahren ausgeben.
    			2. Da die 250 xxx Meldungen vom manchen SMTP-Servern mit mehr als einem Telegramme versendet
    		       werden muss alternativ über Zeitüberwachung eine SSL Sonderbehandlung durchgeführt werden *)
    		IF ssl_mode >= BYTE#1 AND TON_WAIT.ET > T#1s THEN
    			rcv_text := '250-AUTH LOGIN'; (* AUTH vortäuschen *)

            	(*####################  DEBUG-MESSAGE  ###################################*)
    			(*IF _debug_enable THEN
    				LOG_CL.NEW_MSG := 'SMTP: PROBLEM /rcv_text ~1';
    				LOG_CL.PRINTF[1] := rcv_text;
    				LOG_MSG();
    			END_IF*)
    			(*########################################################################*)

    		END_IF

    		IF FIND(rcv_text,'AUTH') > 0 THEN (* BUGFIX  !*)
    			IP_C.MAILBOX[3] := BYTE#1; (* IP Empfang blockieren bis Daten überprüft wurden *)
    			idx1 := 0;
    			step := 50;
    		END_IF

    	END_IF

    50:
    	str2 := ELEMENT_GET(59, idx1, str1); (* Trennzeichen >;< *)

    	(*####################  DEBUG-MESSAGE  ###################################*)
    	(*IF _debug_enable THEN
    		LOG_CL.NEW_MSG := 'ST s1>~1< s2>~2< i1>~2< ~3';
    		LOG_CL.PRINTF[1] := str1;
    		LOG_CL.PRINTF[2] := str2;
    		LOG_CL.PRINTF[3] := INT_TO_STRING(idx1);
    		LOG_CL.PRINTF[4] := rcv_text;
    		LOG_MSG();
    	END_IF*)
    	(*########################################################################*)

    	IF LEN(str2) > 0 THEN
    		IF FIND(rcv_text,str2) > 0 THEN
    			auth_state := BIT_LOAD_B(auth_state, TRUE, idx1);
    			str3 := str2; (* aktuellen AUTH-Type Namen sichern *)
    			idx2 := 1000 + (idx1 * 100); (* Schritt berechnen *)
    		END_IF
    		idx1 := idx1 + 1;
    	ELSE
    		IF auth_state <> BYTE#0 THEN (* AUTH-Type gefunden *)
    			IP_C.MAILBOX[3] := BYTE#0; (* IP Empfang wieder freigeben *)
    			(* mit den jeweiligen Authentifizierung Schritten fortfahren:
    			   1000 = PLAIN / 1100 = LOGIN / 1200 = CRAM-MD5 / 1300 TLS *)
    			step := idx2;
    		ELSE
    			idx1 := 0;
    			rcv_text := '';
    			IP_C.MAILBOX[3] := BYTE#0; (* IP Empfang wieder freigeben *)
    			step := 40; (* warten auf nächste 250 auth meldung *)
    		END_IF
    	END_IF

    	(*####################  DEBUG-MESSAGE  ###################################*)
    	(*IF _debug_enable THEN
    		LOG_CL.NEW_MSG := 'SMTP: /auth ~1 /idx1 ~2 /idx2 ~3 /str3 ~4 /LEN ~5 /step ~6 /str1 ~7';
    		LOG_CL.PRINTF[1] := BYTE_TO_STRING(auth_state);
    		LOG_CL.PRINTF[2] := INT_TO_STRING(idx1);
    		LOG_CL.PRINTF[3] := INT_TO_STRING(idx2);
    		LOG_CL.PRINTF[4] := str3;
    		LOG_CL.PRINTF[5] := INT_TO_STRING(LEN(str2));
    		LOG_CL.PRINTF[6] := INT_TO_STRING(step);
    		LOG_CL.PRINTF[7] := str1;
    		LOG_MSG();
    	END_IF*)
    	(*########################################################################*)

     (* ++++++++++++++++++++++++++++++++++++++++++++++++++++++*)

    90:
    	IF rcv_state = 235 OR rcv_state = 250 THEN (* 235 = Authentication successful / 250 Requested mail action okay *)
    		str2 := MAILFROM;
    		str1 := ELEMENT_GET(59, 0, str2);(* MAILFROM lesen , Trennzeichen >;< *)
    		snd_text := INSERT('MAIL FROM: <>', str1, 12);
    		str3 := REPLACE(snd_text, 'From', 9, 1); (* 'MAIL FROM' durch "From" ersetzen und zwischenspeichern *)
    		next_step := 95;
    		cnt1 := ELEMENT_COUNT(35, MAILTO); (* Trennzeichen >#< , Anzahl der Blöcke bestimmen *)
    		cnt2 := 0;
    	END_IF

    95:	
    	IF rcv_state = 250 THEN (* 250 = Requested mail action okay *)
    		IF cnt2 < cnt1 THEN
    			str1 := ELEMENT_GET(35, cnt2, MAILTO);(* Trennzeichen >#< *)
    			cnt3 := ELEMENT_COUNT(59, str1); (* Trennzeichen >;< , Anzahl der Sub-Blöcke bestimmen *)
    			cnt4 := 0;
    			cnt2 := cnt2 + 1;
    			step := 100; (* Blockinhalt auswerten *)
    		ELSE
    			step := 110; (* alle Blöcke bearbeitet *)
    		END_IF
    	END_IF

    100:
    	IF rcv_state = 250 THEN (* 250 = Requested mail action okay *)
    		IF cnt4 < cnt3 THEN
    			str2 := ELEMENT_GET(59, cnt4, str1); (* Trennzeichen >;< *)
    			snd_text := INSERT('RCPT TO: <>', str2, 10);
    			cnt4 := cnt4 + 1;
    			next_step := 100;
    		ELSE
    			step := 95;
    		END_IF
    	END_IF

    110:
    	IF rcv_state = 250 THEN (* 250 = Requested mail action okay *)
    		snd_text := 'DATA';
    		next_step := 120;
    	END_IF

    120:
    	IF rcv_state = 354 THEN (* 354 = Start mail input; end with. *)
    		snd_enable := FALSE;
    		str2 := MAILFROM;
    		str1 := ELEMENT_GET(59, 1, str2);(* Angezeigter Name lesen , Trennzeichen >;< *)
    		IF LEN(str1) > 0 THEN
    			str2 := INSERT('"" ', str1, 1);
    			snd_text := INSERT(str3, str2, 6);
    		ELSE
    			snd_text := str3;
    		END_IF
    		cnt2 := 0;
    		cnt1 := MIN(2,cnt1); (* BlindCopy Block ausblenden *)
    		step := 200;
    	END_IF

    200:
    	IF snd_step = 0 THEN
    		IF cnt2 < cnt1 THEN
    			str1 := ELEMENT_GET(35, cnt2, MAILTO);(* Trennzeichen >#< *)
    			cnt3 := ELEMENT_COUNT(59, str1); (* Trennzeichen >;< , Anzahl der Sub-Blöcke bestimmen *)
    			cnt4 := 0;
    			cnt2 := cnt2 + 1;
    			str3 := SEL(cnt2 = 1,'Cc: <>','To: <>');
    			step := 205; (* Blockinhalt auswerten *)
    		ELSE
    			step := 210; (* alle Blöcke bearbeitet *)
    		END_IF
    	END_IF

    205:
    	IF snd_step = 0 THEN
    		IF cnt4 < cnt3 THEN
    			str2 := ELEMENT_GET(59, cnt4, str1); (* Trennzeichen >;< *)
    			snd_text := INSERT(str3, str2, 5);
    			cnt4 := cnt4 + 1;
    		ELSE
    			step := 200;
    		END_IF
    	END_IF

    210:
    	IF snd_step = 0 THEN
    		snd_text := CONCAT('SUBJECT: ',SUBJECT);
    		step := 220;
    	END_IF

    220:
    	IF snd_step = 0 THEN
    		DTI := UDINT_TO_DT(DT_TO_UDINT(DTI) + INT_TO_UDINT(- DTI_OFFSET * 60)); (* Minuten-Offset auf Sekunden umrechnen und addieren *)
    		IF esmtp THEN (* esmtp Format >Date: Thu, 21 May 1998 05:33:29 -0700< *)
    			str2 := ';Mon;Tue;Wed;Thu;Fri;Sat;Sun';
    			str1 := ELEMENT_GET(59, DAY_OF_WEEK(DT_TO_DATE(DTI)), str2);
    			snd_text := CONCAT('Date: ',str1);
    			str1 := DT_TO_STRF(DTI, 0, ', #H #E #A #N:#R:#T +0000', 1);
    			snd_text := CONCAT(snd_text,str1);
    		ELSE (* SMTP Format >Date: 21 May 98 05:33:29< *)
    			snd_text := DT_TO_STRF(DTI, 0, 'Date: #G #E #B #N:#R:#T', 1);
    		END_IF
    		step := 230;
    	END_IF

    230:
    	IF snd_step = 0 THEN
    		snd_text := 'MIME-Version: 1.0';
    		step := 250;
    	END_IF

    250:
    	IF snd_step = 0 THEN
    		snd_text := 'Content-Type: multipart/mixed;boundary="x"';
    		snd_lf_cnt := 2;
    		step := 260;
    	END_IF

    260:
    	IF snd_step = 0 THEN
    		snd_enable := TRUE;
    		snd_text := 'This is a multi-part message in MIME format.';
    		step := 270;
    	END_IF

    270:
    	IF snd_step = 0 THEN
    		snd_enable := FALSE;
    		snd_text := '--x';
    		snd_lf_cnt := 1;
    		step := 280;
    	END_IF

    280:
    	IF snd_step = 0 THEN
    		snd_text := 'Content-Type: text/plain; format=flowed; charset="iso-8859-1";';
    		snd_text := CONCAT(snd_text,' reply-type=original'); (* PCWORX kann nur konstanten mit max 80 zeichen *)
    		step := 290;
    	END_IF

    290:
    	IF snd_step = 0 THEN
    		snd_text := 'Content-Transfer-Encoding: 8bit';
    		snd_lf_cnt := 2;
    		step := 300;
    	END_IF

    300:
    	IF snd_step = 0 THEN
    		snd_enable := TRUE;
    		snd_text := BODY;
    		snd_lf_cnt := 2;
    		step := 310;
    	END_IF

    310:
    	IF snd_step = 0 THEN
    		cnt1 := ELEMENT_COUNT(59, FILES) - 1; (* Anzahl der Dateien *)
    		step := 400;
    	END_IF

    (* +++++++++++++ File-Attachment ++++++++++++ *)
    400:
    	IF cnt1 >= 0 THEN
    		str1 := ELEMENT_GET(59, cnt1, FILES);
    		FILE_PATH_SPLIT(FILENAME:=str1,X:=fpd); (* Datei-Path zerlegen *)
    		IF fpd.FILENAME = '#DEL#' THEN
    			file_delete := TRUE;
    		ELSE
    			step := 410;
    		END_IF
    		cnt1 := cnt1 - 1;
    	ELSE
    		step := 800;
    	END_IF

    410:
    	IF snd_step = 0 THEN
    		snd_enable := FALSE;
    		snd_text := '--x';
    		snd_lf_cnt := 1;
    		step := 420;
    	END_IF

    420:
    	IF snd_step = 0 THEN
    		snd_text := 'Content-Transfer-Encoding: BASE64';
    		str2 := CONCAT(fpd.FILENAME,'"');
    		step := 430;
    	END_IF

    430:
    	IF snd_step = 0 THEN
    		snd_text := CONCAT('Content-Type: application/octet-stream; name="',str2);
    		step := 440;
    	END_IF

    440:
    	IF snd_step = 0 THEN
    		snd_enable := TRUE;
    		snd_text := CONCAT('Content-Disposition: attachment; filename="',str2);
    		snd_lf_cnt := 2;
    		step := 450;
    	END_IF

    450:
    	IF snd_step = 0 THEN
    		FSD.FILENAME := str1; (* Dateiname *)
    		FSD.OFFSET := UDINT#0; (* Start bei Dateianfang *)
    		step := 460;
    	END_IF

    460:
    	FSD.MODE := BYTE#1; (* vorhandene Datei zum lesen öffnen *)
    	F_BUF.SIZE := b64_max; (* maximale länge einlesen *)
    	idx1 := 0;
    	idx2 := 0;
    	step := 470;

    470:
    	IF FSD.MODE = BYTE#0 AND FSD.ERROR = BYTE#0 THEN
    		last_block := FSD.FILE_SIZE = FSD.OFFSET;
    		b64_size1 := MIN(48,UINT_TO_INT(F_BUF.SIZE) - idx1);
    		IF b64_size1 > 0 THEN
    			idx3 := b64_size1 - 1;
    			FOR i1 := 0 TO idx3 DO (* daten in BASE64 buffer kopieren *)
    				b64_buf1[i1] := F_BUF.BUFFER[idx1];
    				idx1 := idx1 + 1;
    			END_FOR
    			BASE64_ENCODE_STREAM( SIZE1:= b64_size1, BUF1:= b64_buf1, BUF2:= b64_buf2, SIZE2=> b64_size2); (* BASE64 Kodierung *)
    			idx3 := b64_size2 - 1;
    			FOR i1 := 0 TO idx3 DO (* Daten aus BASE64 buffer kopieren *)
    				S_BUF.BUFFER[idx2] := b64_buf2[i1];
    				idx2 := idx2 + 1;
    			END_FOR
    			b64_lf := TRUE;
    			(*####################  DEBUG-MESSAGE  ###################################*)
    			(*IF _debug_enable THEN
    				LOG_CL.NEW_MSG := 'B64: FILE ~1 /SIZE ~2 /OFF ~3 /BSIZE ~4 /idx1 ~5 /idx2 ~6';
    				LOG_CL.PRINTF[1] := FSD.FILENAME;
    				LOG_CL.PRINTF[2] := UDINT_TO_STRING(FSD.FILE_SIZE);
    				LOG_CL.PRINTF[3] := UDINT_TO_STRING(FSD.OFFSET);
    				LOG_CL.PRINTF[4] := INT_TO_STRING(b64_size1);
    				LOG_CL.PRINTF[5] := INT_TO_STRING(idx1);
    				LOG_CL.PRINTF[6] := INT_TO_STRING(idx2);
    				LOG_MSG();
    			END_IF*)
    			(*########################################################################*)
    		ELSE
    			b64_lf := last_block;
    			step := 480; (* block beendet  *)
    		END_IF
    		IF b64_lf THEN
    			S_BUF.BUFFER[idx2] := BYTE#16#0D;
    			idx2 := idx2 + 1;
    			S_BUF.BUFFER[idx2] := BYTE#16#0A;
    			idx2 := idx2 + 1;
    		END_IF
    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'B64: exit ~1 /SIZE ~2 /OFF ~3 /eof ~4 /lf_cnt ~5';
    			LOG_CL.PRINTF[1] := FSD.FILENAME;
    			LOG_CL.PRINTF[2] := UDINT_TO_STRING(FSD.FILE_SIZE);
    			LOG_CL.PRINTF[3] := UDINT_TO_STRING(FSD.OFFSET);
    			LOG_CL.PRINTF[4] := BOOL_TO_STRING(last_block);
    			LOG_CL.PRINTF[5] := INT_TO_STRING(snd_lf_cnt);
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)
    	END_IF

    480:
    	S_BUF.SIZE := INT_TO_UINT(idx2); (* Daten senden *)
    	(*####################  DEBUG-MESSAGE  ###################################*)
    	(*IF _debug_enable THEN
    		LOG_CL.NEW_MSG := 'B64: tcp_send ~1';
    		LOG_CL.PRINTF[1] := INT_TO_STRING(idx2);
    		LOG_MSG();
    	END_IF*)
    	(*########################################################################*)
    	step := 490;

    490:
    	IF S_BUF.SIZE = UINT#0 THEN (* warten bis alle daten gesendet sind *)
    		step := SEL(last_block ,460,400);
    	END_IF

    (* ++++++++++++++++++++++++++++++++++++++++ *)

    800:
    	IF snd_step = 0 THEN
    		snd_enable := FALSE;
    		snd_text := '--x--';
    		snd_lf_cnt := 2;
    		step := 810;
    	END_IF

    810:
    	IF snd_step = 0 THEN
    		snd_enable := TRUE;
    		snd_text := '.';
    		snd_lf_cnt := 1;
    		step := 820;
    	END_IF

    820:
    	IF rcv_state = 250 THEN (* 250 = Requested mail action okay *)
    		snd_text := 'QUIT';
    		ip_c_red_disable := TRUE;
    		next_step := 830;
    	END_IF

    830:
    	IF rcv_state = 221  OR TON_WAIT.ET > timeout3 THEN (* 221 = Service closing transmission channel *)
    		step := 900;
    	END_IF

    (* ================================================== *)

    900:
    	IF file_delete THEN (* Dateien nach transfer löschen *)
    		cnt1 := ELEMENT_COUNT(59, FILES) - 1; (* Trennzeichen >;< , Anzahl der Dateien *)
    		step := 910;
    	ELSE
    		step := 950;
    	END_IF

    910:
    	IF FSD.MODE = BYTE#0 AND FSD.ERROR = BYTE#0 THEN
    		IF cnt1 >= 0 THEN
    			str1 := ELEMENT_GET(59, cnt1, FILES); (* Trennzeichen >;< *)
    			IF str1 <> '#DEL#' THEN
    				FSD.FILENAME := str1;
    				FSD.MODE := BYTE#4; (* File Remove *)
    			END_IF
    			cnt1 := cnt1 - 1;
    		ELSE
    			step := 950;
    		END_IF
    	END_IF

    950:
    	DONE := TRUE;
    	step := 980;

    980:
    	IP_C.C_ENABLE := FALSE; (* SMTP Steuerkanal schliessen *)
    	S_BUF.SIZE := UINT#0;
    	R_BUF.SIZE := UINT#0;
    	IP_C.MAILBOX[3] := BYTE#0; (* IP Empfang wieder freigeben *)
    	snd_step := 0;
    	next_step := 0;
    	FSD.MODE := BYTE#5; (* Datei schliessen *)
    	step := 990;

    990:
    	IF IP_C.C_STATE = BYTE#0 AND FSD.FILE_OPEN = FALSE THEN
    		step := 0;
    	END_IF

    (*  +++++++++++++++++ Authentifizierung +++++++++++++++++ *)

    (* PLAIN ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

    1000:
    	snd_text := CONCAT('AUTH',str3);
    	snd_lf_cnt := 1;
     	step := 1010;

    1010:
    	IF rcv_state = 334 THEN (* 334 = Authentifizierung  *)
    		cnt1 := LEN(URL_DATA.USER);
    		cnt2 := LEN(URL_DATA.PASSWORD);
    		IF cnt1 + cnt2 <= 46 THEN (* USER + PASSWORD dürfen zusammen maximal 46 Zeichen haben *)
    			b64_buf1[0] := BYTE#0;
    			FOR i1 := 1 TO cnt1 DO
    				b64_buf1[i1] := CODE(URL_DATA.USER, i1);
    			END_FOR
    			b64_size1 := cnt1 + 1;
    			b64_buf1[b64_size1] := BYTE#0;
    			b64_size1 := b64_size1 + 1;
    			FOR i1 := 1 TO cnt2 DO
    				b64_buf1[b64_size1] := CODE(URL_DATA.PASSWORD, i1);
    				b64_size1 := b64_size1 + 1;
    			END_FOR
    			BASE64_ENCODE_STREAM( SIZE1:= b64_size1, BUF1:= b64_buf1, BUF2:= b64_buf2, SIZE2=> b64_size2); (* BASE64 Kodierung *)
    			idx1 := b64_size2 - 1;
    			FOR i1 := 0 TO idx1 DO
    				S_BUF.BUFFER[i1] := b64_buf2[i1];
    			END_FOR
    			S_BUF.BUFFER[b64_size2] := BYTE#16#0D;
    			b64_size2 := b64_size2 + 1;
    			S_BUF.BUFFER[b64_size2] := BYTE#16#0A;
    			b64_size2 := b64_size2 + 1;
    			S_BUF.SIZE := INT_TO_UINT(b64_size2);
    			rcv_state := 0;
    		END_IF
    		step := 90;
    	END_IF

    (* LOGIN ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

    1100:
    	snd_text := CONCAT('AUTH',str3);
    	snd_lf_cnt := 1;
     	step := 1110;

    1110:
    	IF rcv_state = 334 THEN (* 334 = Authentifizierung  *)
    		b64_str1 := URL_DATA.USER;
    		b64_start := TRUE; (* BASE64 kodierung von Username *)
    		step := 1120;
    	END_IF

    1120:
    	IF b64_start AND b64_done THEN
    		b64_start := FALSE;
    		snd_text := b64_str2;
    		next_step := 1130;
    	END_IF

    1130:
    	IF rcv_state = 334 THEN (* 334 = Password:  *)
    		b64_str1 := URL_DATA.PASSWORD;
    		b64_start := TRUE; (* BASE64 kodierung von Password *)
    		step := 1140;
    	END_IF

    1140:
    	IF b64_start AND b64_done THEN
    		b64_start := FALSE;
    		snd_text := b64_str2;
    		next_step := 90;
    	END_IF

    (* CRAM-MD5  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    (Challenge-Response Authentication Mechanism, Message Digest 5) Authentifizierung auf Basis von MD5-HMAC-Algorithmus. *)

    1200:
    	snd_text := CONCAT('AUTH',str3);
    	snd_lf_cnt := 1;
     	step := 1210;

    1210:
    	IF rcv_state = 334 THEN (* 334 = Authentifizierung  *)
    		md5_b64_ts := RIGHT(rcv_text,LEN(rcv_text) - 4);
    		md5_user := URL_DATA.USER;
    		md5_password := URL_DATA.PASSWORD;
    		MD5_RUN := TRUE;
    		step := 1220;
    	END_IF

    1220:
    	MD5_CRAM_AUTH(RUN:=MD5_RUN,USERNAME:=md5_user,PASSWORD:=md5_password,B64_TS:=md5_b64_ts,AUTH_KEY:=md5_auth_key);
    	IF NOT MD5_RUN THEN
    		snd_text := md5_auth_key;
    		step := 90;
    	END_IF

    (* STARTTLS  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

    1300:
    	snd_text := 'STARTTLS';
    	snd_lf_cnt := 1;
     	step := 1310;

    1310:
    	IF rcv_state = 220 THEN (* 220 = Service ready - Ready to start TLS *)
    		IP_C.MAILBOX[16] := BYTE#1; (* SSL/TLS aktivieren *)
    		step := 1320;
    	END_IF

    1320:
    	IF IP_C.MAILBOX[16] = BYTE#2 THEN (* warten bis SSL/TLS aktiviert wurde *)
    		step := 30; (* ganzer Ablauf von vorne beginnen *)
    	END_IF

    (* keine Authentifizierung gefunden +++++++++++++++++++++++++++++++ *)
    1900: ; (* Auf Laufzeitfehler warten *)

    END_CASE
    (* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
    IF step >= 30 THEN
    	IF R_BUF.SIZE > UINT#0 THEN (* Daten wurden empfangen ? *)
    		idx1 := UINT_TO_INT(R_BUF.SIZE);
    		REPEAT (* zeilenterminierung erkennen und echtes TEXT-Ende bestimmen *)
    			idx1 := idx1 - 1;
    		UNTIL idx1 = 0 OR R_BUF.BUFFER[idx1] >= BYTE#32 (* TRUE = EXIT *)
    		END_REPEAT
    		FOR i1 := 0 TO idx1 DO (* bei multiline alle CRLF durch >< ersetzen *)
    			IF R_BUF.BUFFER[i1] < BYTE#32 THEN
    				R_BUF.BUFFER[i1] := BYTE#94; (* >< *)
    			END_IF
    		END_FOR
    		rcv_text := BUFFER_TO_STRING(PT:=ADR(R_BUF.BUFFER),SIZE:=idx1+1,START:=0,STOP:=STRING_LENGTH-1);
    		IF LEN(rcv_text) >= 3 THEN (* Statuscode prüfen und auswerten *)
    			rcv_s := LEFT(rcv_text,3);
    			IF IS_NUM(STR:=rcv_s) THEN (* enthält nur Zahlen ? *)
    				rcv_state := STRING_TO_INT(rcv_s);
    			END_IF
    			IP_C.R_OBSERVE := FALSE;
    		END_IF
    		R_BUF.SIZE := UINT#0; (* daten löschen *)

    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'RCV: >~1<';
    			LOG_CL.PRINTF[1] := rcv_text;
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)

    	END_IF
    END_IF

    (* automatisches Datensenden *)

    CASE snd_step OF

    00:
    	IF LEN(snd_text) > 0 THEN

    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'SND: >~1< /lf ~2';
    			LOG_CL.PRINTF[1] := snd_text;
    			LOG_CL.PRINTF[2] := INT_TO_STRING(snd_lf_cnt);
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)

    		_STRING_TO_BUFFER(str:=snd_text,pos:=snd_idx,pt:=ADR(S_BUF.BUFFER),size:=SIZEOF(S_BUF.BUFFER)); (* String in puffer kopieren *)
    		snd_idx := snd_idx + LEN(snd_text);
    		FOR i1 := 1 TO snd_lf_cnt DO
    			S_BUF.BUFFER[snd_idx] := BYTE#16#0D;
    			snd_idx := snd_idx + 1;
    			S_BUF.BUFFER[snd_idx] := BYTE#16#0A;
    			snd_idx := snd_idx + 1;
    		END_FOR
    		snd_text := '';
    		rcv_state := 9999; (* letzen SMTP Status löschen *)

    		IF snd_enable THEN
    			S_BUF.SIZE := INT_TO_UINT(snd_idx); (* Sendelänge eintragen *)
    			R_BUF.SIZE := UINT#0; (* Empfangsbuffer rücksetzen *)
    			IP_C.R_OBSERVE := step <= 120 OR step >= 820;
    			snd_idx := 0;
    			snd_step := 10;
    		END_IF
    	END_IF

    10:
    	IF S_BUF.SIZE = UINT#0 THEN (* warten bis alle daten gesendet sind *)
    		IF next_step <> 0 THEN
    			step := next_step;
    			next_step := 0;
    		END_IF
    		snd_step := 0;
    	END_IF

    END_CASE

    (* Globale Fehlerbehandlung für Haupt-Routine *)
    IF ERROR_T = BYTE#0 AND step > 20 THEN (* noch kein Fehler gespeichert und Hauptroutine aktiv *)

    	IF IP_C.ERROR > DWORD#0 AND IP_C.C_ENABLE AND NOT IP_C.TIME_RESET THEN  (* IP Control 1 *)
    		IF ip_c_red_disable = FALSE OR IP_C.ERROR <> DWORD#16#FD000000 THEN
    			ERROR_C := IP_C.ERROR;
    			ERROR_T := BYTE#2;
    			step := 980;
    		END_IF
    	END_IF

    	IF FSD.MODE = BYTE#0 THEN
    		IF FSD.ERROR > BYTE#0 THEN
    			ERROR_C := BYTE_TO_DWORD(FSD.ERROR);
    			ERROR_T := BYTE#4; (* Dateizugriff *)
    			step := 980;
    		END_IF
    	END_IF
    END_IF

    IF TON_WAIT.Q THEN (* Ablaufstörung - Schrittkette *)
    	ERROR_C := SHL(INT_TO_DWORD(step),16) OR INT_TO_DWORD(rcv_state); (* aktuellen Schritt und letzten SMTP Status eintragen *)
    	ERROR_T := BYTE#5;
    	step := 980;
    END_IF

    (* ######################################################## *)

    DNS_CLIENT(IP_C:=IP_C, S_BUF:=S_BUF, R_BUF:=R_BUF, DOMAIN:=URL_DATA.DOMAIN, IP4_DNS:= DNS_IP4, ACTIVATE:=step=10); (* DNS-Client *)
    IPC(IP:= DWORD#0, PORT:= WORD#0 , TIME_OUT:= TIMEOUT, IP_C:= IP_C, S_BUF:= S_BUF, R_BUF:= R_BUF); (* SMTP Steuerkanal *)
    FS(FSD:=FSD,PT:=F_BUF); (* FILE_SERVER *)
    BASE64_ENCODE_STR(RUN:= b64_start, str1:= b64_str1, str2:= b64_str2, DONE=> b64_done); (* BASE64 kodierung *)

    TON_WAIT(IN:=step = last_step AND step > 0,PT:=timeout2);
    last_step := step;
    activate_last := ACTIVATE;
    BUSY := step <> 0;

    (* revision history
    ks	01. jan. 2011	rev 1.0
    	original version
    ks	06. apr. 2011	rev 1.1
    	list_len und list_get durch element_count und element_get ersetzt
    ks	11. may 2011	rev 1.2
    	ip_control - remote disconnect error ausblenden, und sonderbehandlung für pcworx
    ks	30. may 2011	rev 1.3
    	fehler bei receive-TIMEOUT
    ks	05. may. 2012	rev 1.4
    	FileServer AutoClose entfernt und Fehler im Alias Name korrigiert
    ks	06. apr. 2013	rev 1.5
    	Fehler bei Authorisierungsabfrage bei 1&1 Provider behoben
    ks	22. feb. 2016	rev 1.6
    	integration SSL/TLS
    ks	11. aug. 2016	rev 1.7
    	bugfix: Find SSL/TLS String in URL_DATA.PROTOCOL
    *)
END_FUNCTION_BLOCK
