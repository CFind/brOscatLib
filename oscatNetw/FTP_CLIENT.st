FUNCTION_BLOCK FTP_CLIENT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=94*)
    CASE step OF

    00:	IF ACTIVATE AND NOT activate_last THEN
    		ftp_file_size := UDINT#0;
    		TIMEOUT := MAX(T#10s,TIMEOUT);
    		timeout2 := TIMEOUT + T#1s;
    		timeout3 := TIMEOUT / 2;
    		DONE := FALSE;
    		ip_c1_red_disable := FALSE;
    		ip_c2_red_disable := FALSE;
    		ERROR_C := DWORD#0;
    		ERROR_T := BYTE#0;
    		FSD.ERROR := BYTE#0;
    		URL_DATA := STRING_TO_URL(STR:=FTP_URL,DEFAULT_PROTOCOL:='',DEFAULT_PATH:='/');
    		IF LEN(URL_DATA.USER) = 0 THEN
    			URL_DATA.USER := 'Anonymous';
    			URL_DATA.PASSWORD := 'User@';
    		END_IF

    		FILE_PATH_SPLIT(FILENAME:=FILENAME,X:=fpd); (* Datei-Path zerlegen *)
    		str1 := fpd.FILENAME; (* zwischenspeichern *)
    		FILE_PATH_SPLIT(FILENAME:=URL_DATA.PATH,X:=fpd); (* FTP-Path zerlegen *)
    		IF LEN(fpd.FILENAME) = 0 THEN (* wenn FTP-Path keinen Dateinamen enthält , dann den Namen der lokalen Datei benutzen *)
    			ftp_path := CONCAT(URL_DATA.PATH,str1);
    		ELSE
    			ftp_path := URL_DATA.PATH;
    		END_IF
    		step := 10;
    	END_IF

    10:	IF DNS_CLIENT.DONE THEN
    		step := 20;
    	ELSIF DNS_CLIENT.ERROR <> DWORD#0 THEN
    		ERROR_C := DNS_CLIENT.ERROR;
    		ERROR_T := BYTE#1;
    		step := 980;
    	END_IF

    20:	(* FTP Steuerkanal einrichten *)
    	IP_C1.C_PORT := WORD#21; (* Portnummer eintragen *)
      	IP_C1.C_IP := DNS_CLIENT.IP4; (* IP eintragen *)
      	IP_C1.C_MODE := BYTE#0; (* Mode: TCP+ACTIV+PORT *)
      	IP_C1.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
      	IP_C1.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
      	IP_C1.R_OBSERVE := TRUE; (* Empfangsueberwachung *)
    	R_BUF1.SIZE := UINT#0;

      	IP_C2.C_ENABLE   := FALSE; (* Verbindungsaufbau sperren *)
    	step := 30;

    30:	IF rcv_state = 220 THEN (* 220 = Service ready for new user *)
    		snd_text := CONCAT('USER ',URL_DATA.USER);
    		next_step := 40;
    	END_IF

    40:	IF rcv_state = 331 THEN (* 331 = User name okay, need password *)
    		snd_text := CONCAT('PASS ',URL_DATA.PASSWORD);
    		next_step := 50;
    	ELSIF rcv_state = 230 THEN (* 230 = User logged in, proceed *)
    		next_step := 50;
    	ELSIF rcv_state = 220 THEN (* 220 = Service ready for new user *)
    		next_step := 20; (* WORK verbindung sollte ab/aufgebaut werden *)
    	END_IF

    50:	IF rcv_state = 230 THEN (* 230 = User logged in, proceed *)
    		snd_text := 'TYPE I';  (* binären Modus aktivieren *)
    		next_step := 54;
    	END_IF

    54:	IF rcv_state = 200 THEN (* 200 = Command okay *)
    		IF FTP_DOWNLOAD THEN (* Datei von FTP Empfangen *)
    			snd_text := CONCAT('SIZE ', ftp_path); (* SIZE /PFAD/FILENAME *)
    			next_step := 56;
    		ELSE
    			step := 60;
    		END_IF
    	END_IF

    56:	IF rcv_state = 213 THEN (* 213 Filesize *)
    		str1 := ELEMENT_GET(SEP:=BYTE#32,POS:=1,ELEMENT:=rcv_text);
    		ftp_file_size := STRING_TO_UDINT(str1); (* Dateigroesse in bytes gestimmen *)
    		step := 60;
    	END_IF

    60:	IF FTP_ACTIV THEN (* FTP Server aktiv *)
    		IF URL_DATA.PORT = WORD#0 THEN
    			URL_DATA.PORT := WORD#20; (* Standard Datenkanal *)
    		END_IF
    		str2 := '';
    		dw_tmp := PLC_IP4;
    		FOR idx1 := 0 TO 5 DO
    			IF idx1 = 4 THEN
    				dw_tmp := ROR(WORD_TO_DWORD(URL_DATA.PORT),8);
    			ELSE
    				dw_tmp := ROL(dw_tmp,8);
    			END_IF
    			str2 := CONCAT(str2,BYTE_TO_STRING(DWORD_TO_BYTE(dw_tmp)));
    			IF idx1 < 5 THEN
    				str2 := CONCAT(str2,',');
    			END_IF
    		END_FOR
    		dw_tmp := DNS_CLIENT.IP4; (* IP eintragen *)
    		w_tmp := URL_DATA.PORT; (* Port Nummer des Datenkanals *)
    		snd_text := CONCAT('PORT ',str2); (* FTP Server in den aktiv-mode schalten *)
    		next_step := 80;
    	ELSE
    		snd_text := 'PASV';  (* FTP Server in den passiv-mode schalten *)
    		next_step := 70;
    	END_IF
    	step := 999; (* Warten auf next_step *)

    70:	IF rcv_state = 227 THEN (* 227 = Entered Passive Mode (213,202,225,43,212,186) *)
    		idx1 := FIND(rcv_text , '(' );
    		idx2 := FIND(rcv_text , ')' );
    		IF idx1 > 0 AND idx2 > idx1+1 THEN
    			str1 := MID(rcv_text, idx2 - idx1 - 1, idx1+1);
    			FOR idx1 := 0 TO 5 DO
    				str2 := ELEMENT_GET(SEP:=BYTE#44,POS:=idx1,ELEMENT:=str1);
    				byar[idx1] := STRING_TO_BYTE(str2);
    			END_FOR
    			dw_tmp := DWORD_OF_BYTE(byar[0],byar[1],byar[2],byar[3]); (* IP Adresse des Datenkanals *)
    			w_tmp := WORD_OF_BYTE(byar[4],byar[5]); (* Port Nummer des Datenkanals *)
    		END_IF
    		step := 100;
    	END_IF

    80:	IF rcv_state = 200 THEN (* 200 = PORT command successful *)
    		step := 100;
    	END_IF

    100:IP_C2.C_MODE := SEL(FTP_ACTIV,BYTE#0,BYTE#2); (* Aktiv = Mode 2: TCP+PASSIV+PORT / passiv = Mode 0: TCP+ACTIV+PORT *)
    	IP_C2.C_IP := dw_tmp; (* IP Adresse des Datenkanals *)
    	IP_C2.C_PORT := w_tmp; (* Port Nummer des Datenkanals *)
      	IP_C2.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
      	IP_C2.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
    	IP_C2.R_OBSERVE := FALSE; (* Empfangsueberwachung *)
    	R_BUF2.SIZE := UINT#0;
    	step := 120;

    120:IF IP_C2.C_STATE > BYTE#127 THEN (* FTP Datenkanal aufgebaut *)
    		IF FTP_DOWNLOAD THEN (* File von FTP empfangen *)
    			IP_C2.MAILBOX[3] := BYTE#1; (* IP Empfang sperren *)
    			step := 400;
    		ELSE
    			snd_text := 'STOR ';
    			next_step := 140;
    			snd_text := CONCAT(snd_text, ftp_path); (* STORE /PFAD/FILENAME *)
    			step := 999; (* Warten auf next_step *)
    		END_IF
    	END_IF

    (* ============== File an FTP senden ================ *)

    140:IF rcv_state = 125 OR rcv_state = 150 THEN (* 125 = Data connection already open / 150 = File status okay; about to open data connection *)
    		step := 160;
    	END_IF

    160:FSD.FILENAME := FILENAME; (* Dateiname *)
    	FSD.MODE := BYTE#1; (* vorhandene Datei zum lesen öffnen *)
    	FSD.OFFSET := UDINT#0; (* Start bei Dateianfang *)
    	S_BUF2.SIZE := UINT#65535; (* maximale länge einlesen *)
    	IP_C2.MAILBOX[2] := BYTE#1; (* IP Senden blockieren *)
    	step := 200;

    200:IF FSD.MODE = BYTE#0 AND FSD.ERROR = BYTE#0 THEN
    		IP_C2.MAILBOX[2] := BYTE#0; (* IP Senden erlauben *)
    		step := 210;
    	END_IF

    210:IF S_BUF2.SIZE = UINT#0 THEN (* warten bis alle daten gesendet sind *)
    		IF FSD.FILE_SIZE - FSD.OFFSET > UDINT#0 THEN
    			FSD.MODE := BYTE#1; (* vorhandene Datei zum lesen öffnen *)
    			S_BUF2.SIZE := UINT#65535; (* maximale länge einlesen *)
    			IP_C2.MAILBOX[2] := BYTE#1; (* IP Senden blockieren *)
    			step := 200;
    		ELSE
    			IP_C2.C_ENABLE := FALSE; (* FTP Datenkanal schliessen *)
    			step := 300;
    		END_IF
    	END_IF

    300:IF rcv_state = 226 THEN (* 226 Closing data connection. Requested file action successful  *)
    		snd_text := 'QUIT';
    		ip_c1_red_disable := TRUE;
    		next_step := 320;
    	END_IF

    320:IF rcv_state = 221 OR TON_WAIT.ET > timeout3  THEN (* 221 Service closing control connection *)
    		IP_C1.C_ENABLE := FALSE; (* FTP Steuerkanal schliessen *)
    		IF FILE_DELETE THEN (* Datei nach transfer löschen *)
    			FSD.MODE := BYTE#4; (* File Remove *)
    			step := 340;
    		ELSE
    			step := 900;
    		END_IF
    	END_IF

    340:IF FSD.MODE = BYTE#0 AND FSD.ERROR = BYTE#0 THEN
    		step := 900;
    	END_IF

    (*  ============== File vom FTP Empfangen  ============== *)

    400:snd_text := 'RETR ';
    	next_step := 410;
    	snd_text := CONCAT(snd_text, ftp_path); (* RETR /PFAD/FILENAME *)
    	step := 999; (* Warten auf next_step *)

    410:IF rcv_state = 125 OR rcv_state = 150 THEN (* 125 = Data connection already open / 150 = File status okay; about to open data connection *)
    		IP_C2.R_OBSERVE := TRUE; (* Empfangsueberwachung *)
    		step := 420;
    	END_IF

    420:FSD.FILENAME := FILENAME; (* Dateiname *)
    	FSD.MODE := BYTE#3; (* Datei neu anlegen *)
    	FSD.OFFSET := UDINT#0; (* Start bei Dateianfang *)
    	step := 460;

    440:IF R_BUF2.SIZE > UINT#0 THEN (* warten bis daten empfangen wurden *)
    		IP_C2.MAILBOX[3] := BYTE#1; (* IP Empfang blockieren bis Daten in Datei geschrieben wurden *)
    		FSD.MODE := BYTE#3; (* Daten in Datei schreiben *)
    		step := 460;
    	ELSIF FSD.FILE_SIZE = ftp_file_size THEN (* Verbindung abgebaut ? , oder 226 = Closing data connection. Requested file action successful *)
    		IP_C2.C_ENABLE := FALSE; (* FTP Datenkanal schliessen *)
    		ip_c2_red_disable := TRUE;
    		step := 700;
    	END_IF

    460:IF FSD.MODE = BYTE#0 AND FSD.ERROR = BYTE#0 THEN (* warten bis Daten geschreiben wurden *)
    		R_BUF2.SIZE := UINT#0; (* Daten löschen *)
    		IP_C2.MAILBOX[3] := BYTE#0; (* IP Empfang wieder erlauben *)
    		step := 440;
    	END_IF

    (* ================================================== *)

    700:IF rcv_state = 226 OR  TON_WAIT.ET > timeout3 THEN (* 226 Closing control connection. Requested file action successful  *)
    		IF FTP_DOWNLOAD AND FILE_DELETE THEN (* FTP Download und File löschen ? *)
    			snd_text := CONCAT('DELE ', ftp_path); (* DELE /PFAD/FILENAME *)
    			next_step := 720;
    		ELSE
    			step := 740;
    		END_IF
    	END_IF

    720:IF rcv_state = 250 THEN (* 250 Requested file action okay, completed *)
    		step := 740;
    	END_IF

    740:snd_text := 'QUIT';
    	ip_c1_red_disable := TRUE;
    	next_step := 760;
    	step := 999; (* Warten auf next_step *)

    760:IF rcv_state = 221 OR TON_WAIT.ET > timeout3 THEN (* 221 Service closing control connection  *)
    		IP_C1.C_ENABLE := FALSE; (* FTP Steuerkanal schliessen *)
    		IF NOT FTP_DOWNLOAD AND FILE_DELETE THEN (* FTP Upload und Datei nach transfer löschen *)
    			FSD.MODE := BYTE#4; (* File Remove *)
    			step := 780;
    		ELSE
    			step := 900;
    		END_IF
    	END_IF

    780:IF FSD.MODE = BYTE#0 AND FSD.ERROR = BYTE#0 THEN
    		step := 900;
    	END_IF

    (* ================================================== *)

    900:DONE := TRUE;
    	step := 980;

    980:IP_C1.C_ENABLE := FALSE; (* FTP Steuerkanal schliessen *)
    	IP_C2.C_ENABLE := FALSE; (* FTP Datenkanal schliessen *)
    	IP_C2.MAILBOX[2] := BYTE#0; (* IP Senden wieder erlauben *)
    	IP_C2.MAILBOX[3] := BYTE#0; (* IP Empfang wieder erlauben *)
    	S_BUF1.SIZE := UINT#0;
    	S_BUF2.SIZE := UINT#0;
    	R_BUF1.SIZE := UINT#0;
    	R_BUF2.SIZE := UINT#0;
    	ftp_file_size := UDINT#0;
    	snd_step := 0;
    	next_step := 0;
    	FSD.MODE := BYTE#5; (* Datei schliessen *)
    	step := 990;

    990:IF IP_C1.C_STATE = BYTE#0 AND IP_C2.C_STATE = BYTE#0 AND FSD.FILE_OPEN = FALSE THEN
    		step := 0;
    	END_IF

    999: ; (* Dummy Schritt, warten bis neuer schritt durch "next_step" aktiv wird *)

    END_CASE

    (* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

    IF step >= 30 THEN
    	IF R_BUF1.SIZE > UINT#0 THEN (* Daten wurden empfangen ? *)
    		idx1 := UINT_TO_INT(R_BUF1.SIZE);
    		REPEAT (* zeilenterminierung erkennen und echtes TEXT-Ende bestimmen *)
    			idx1 := idx1 - 1;
    		UNTIL idx1 = 0 OR R_BUF1.BUFFER[idx1] >= BYTE#32 (* TRUE = EXIT *)
    		END_REPEAT
    		idx1 := idx1 + 1; (* index auf SIZE umrechnen *)
    		rcv_text := BUFFER_TO_STRING(PT:=ADR(R_BUF1.BUFFER),SIZE:=idx1,START:=0,STOP:=STRING_LENGTH-1);
    		IF LEN(rcv_text) >= 3 THEN (* Statuscode prüfen und auswerten *)
    			str1 := LEFT(rcv_text,3);
    			IF IS_NUM(STR:=str1) THEN (* enthält nur Zahlen ? *)
    				rcv_state := STRING_TO_INT(str1);
    			END_IF
    			IP_C1.R_OBSERVE := FALSE;
    		END_IF
    		R_BUF1.SIZE := UINT#0; (* daten löschen *)

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

    00:	IF LEN(snd_text) > 0 THEN
    	        (*####################  DEBUG-MESSAGE  ###################################*)
    	        (*IF _debug_enable THEN
    	          LOG_CL.NEW_MSG := 'SND: >~1<';
    	          LOG_CL.PRINTF[1] := snd_text;
    	          LOG_MSG();
    	        END_IF*)
    	        (*########################################################################*)
    		_STRING_TO_BUFFER(str:=snd_text,pos:=0,pt:=ADR(S_BUF1.BUFFER),size:=SIZEOF(S_BUF1.BUFFER)); (* String in puffer kopieren *)
    		idx1 := LEN(snd_text);
    		S_BUF1.BUFFER[idx1] := BYTE#16#0D;
    		idx1 := idx1 + 1;
    		S_BUF1.BUFFER[idx1] := BYTE#16#0A;
    		idx1 := idx1 + 1;
    		S_BUF1.SIZE := INT_TO_UINT(idx1); (* Sendelänge eintragen *)
    		R_BUF1.SIZE := UINT#0; (* Empfangsbuffer rücksetzen *)
    		IP_C1.R_OBSERVE := TRUE;
    		rcv_state := 9999; (* letzen FTP Status löschen *)
    		snd_text := '';
    		snd_step := 10;
    	END_IF

    10:	IF S_BUF1.SIZE = UINT#0 THEN (* warten bis alle daten gesendet sind *)
    		step := next_step;
    		snd_step := 0;
    	END_IF

    END_CASE

    (* Globale Fehlerbehandlung für Haupt-Routine *)
    IF ERROR_T = BYTE#0 AND step > 20 THEN (* noch kein Fehler gespeichert und Hauptroutine aktiv *)

    	IF IP_C1.ERROR > DWORD#0 AND IP_C1.C_ENABLE AND NOT IP_C1.TIME_RESET THEN  (* IP Control 1 *)
    		IF ip_c1_red_disable = FALSE OR IP_C1.ERROR <> DWORD#16#FD000000 THEN
    			ERROR_C := IP_C1.ERROR;
    			ERROR_T := BYTE#2;
    			step := 980;
    		END_IF
    	END_IF

    	IF IP_C2.ERROR > DWORD#0 AND IP_C2.C_ENABLE AND NOT IP_C2.TIME_RESET THEN  (* IP Control 2 *)
    		IF ip_c2_red_disable = FALSE OR IP_C2.ERROR <> DWORD#16#FD000000 THEN
    			ERROR_C := IP_C2.ERROR;
    			ERROR_T := BYTE#3;
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
    	ERROR_C := SHL(INT_TO_DWORD(step),16) OR INT_TO_DWORD(rcv_state); (* aktuellen Schritt und letzten FTP Status eintragen *)
    	ERROR_T := BYTE#5;
    	step := 980;
    END_IF

    (* ######################################################## *)

    DNS_CLIENT(IP_C:=IP_C1, S_BUF:=S_BUF1, R_BUF:=R_BUF1, DOMAIN:=URL_DATA.DOMAIN, IP4_DNS:= DNS_IP4, ACTIVATE:=step=10); (* DNS-Client *)
    IPC1(IP:= DWORD#0, PORT:= WORD#0 , TIME_OUT:= TIMEOUT, IP_C:= IP_C1, S_BUF:= S_BUF1, R_BUF:= R_BUF1); (* FTP Steuerkanal *)
    IPC2(IP:= DWORD#0, PORT:= WORD#0 , TIME_OUT:= TIMEOUT, IP_C:= IP_C2, S_BUF:= S_BUF2, R_BUF:= R_BUF2); (* FTP Datenkanal *)

    TON_WAIT(IN:=step = last_step AND step > 0,PT:=timeout2);
    last_step := step;
    activate_last := ACTIVATE;
    BUSY := step <> 0;

    IF FTP_DOWNLOAD THEN (* FILE_SERVER *)
    	FS(FSD:=FSD,PT:=R_BUF2); (* Datei von FTP empfangen *)
    ELSE
    	FS(FSD:=FSD,PT:=S_BUF2); (* Datei an FTP senden *)
    END_IF

    (* revision history
    ks	05. may 2011	rev 1.3
    	FileServer AutoClose entfernt

    ks	11. may 2011	rev 1.2
    	ip_control - remote disconnect error ausblenden, und sonderbehandlung für pcworx

    ks	06. apr. 2011	rev 1.1
    	list_len und list_get durch element_count und element_get ersetzt

    ks	01. jan. 2011	rev 1.0
    	original version
    *)
END_FUNCTION_BLOCK
