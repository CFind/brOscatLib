FUNCTION_BLOCK UNI_CIRCULAR_BUFFER
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=69*)
    CASE DATA.D_MODE OF

    01:	x := WORD_TO_BYTE(DATA.D_HEAD); (* nur rechtes byte auswerten *)
    	CASE x OF
    	01:	cnt := LEN(DATA.D_STRING); (* String verarbeiten *)
    		pTmp := ADR(DATA.D_STRING);
    	02:	cnt := 4; (* Real verarbeiten *)
    		pTmp := ADR(DATA.D_REAL);
    	03:	cnt := 4; (* DWORD verarbeiten *)
    		pTmp := ADR(DATA.D_DWORD);
    	ELSE
    		cnt := 0;
    	END_CASE

    	DATA.BUF_DATA_CNT := DATA.BUF_DATA_CNT + UDINT#1;

    	(* ------ Daten in buffer eintragen ------ *)
    	buf_totalsize := SIZEOF(DATA.BUF);

    	IF (cnt + HeaderSize) > (buf_totalsize - DATA.BUF_SIZE) THEN (* genug Speicher frei ? *)
    		DATA.BUF_DATA_LOST := DATA.BUF_DATA_LOST + UDINT#1;
    		RETURN;
    	END_IF

    	DATA.D_SIZE := cnt;

    	mode_last := DATA.D_MODE;
    	tmp_dw := SHL(WORD_TO_DWORD(DATA.D_HEAD),16) OR UINT_TO_DWORD(cnt);

    	(* Header in Buffer eintragen *)
    	n1 := 0;
    	REPEAT
    		n2 := MIN(HeaderSize - n1, buf_totalsize - DATA._Last);
    		FOR n := 1 TO n2 DO
    			tmp_dw := ROL(tmp_dw,8);
    			DATA.BUF[DATA._Last] := DWORD_TO_BYTE(tmp_dw);
    			DATA._Last := DATA._Last + 1;
    		END_FOR
    		IF DATA._Last >= buf_totalsize THEN
    			DATA._Last := 0;
    		END_IF
    		n1 := n1 + n2;
    	UNTIL n1 >= HeaderSize
    	END_REPEAT

    	(* Daten in Buffer eintragen *)
    	n1 := 0;
    	REPEAT
    		n2 := MIN(cnt - n1, buf_totalsize - DATA._Last);
    		FOR n := 1 TO n2 DO
    			DATA.BUF[DATA._Last] := pTmp;
    			pTmp := pTmp + 1;
    			DATA._Last := DATA._Last + 1;
    		END_FOR
    		IF DATA._Last >= buf_totalsize THEN
    			DATA._Last := 0;
    		END_IF
    		n1 := n1 + n2;
    	UNTIL n1 >= cnt
    	END_REPEAT

    	DATA.BUF_SIZE := DATA.BUF_SIZE + cnt + HeaderSize;
    	DATA.BUF_COUNT := DATA.BUF_COUNT + 1;
    	DATA.BUF_USED := UINT_TO_USINT(100 * DATA.BUF_SIZE / buf_totalsize); (* benützer Speicher in % *)
    	DATA.D_MODE := 0;

    	(*####################  DEBUG-MESSAGE  ###################################*)
    	(*IF _debug_enable THEN
    		LOG_CL.NEW_MSG := 'RP: ADD /HEAD ~1 / SIZE ~2 / cnt ~3 / >~4<';
    		LOG_CL.PRINTF[1] := DWORD_TO_STRH(DATA.D_HEAD);
    		LOG_CL.PRINTF[2] := UINT_TO_STRING(cnt);
    		LOG_CL.PRINTF[3] := UINT_TO_STRING(DATA.BUF_COUNT);
    		CASE x OF
    		01:	LOG_CL.PRINTF[4] := DATA.D_STRING;
    		02:	LOG_CL.PRINTF[4] := REAL_TO_STRING(DATA.D_REAL);
    		03:	LOG_CL.PRINTF[4] := DWORD_TO_STRH(DATA.D_DWORD);
    		ELSE
    			LOG_CL.PRINTF[4] := '';
    		END_CASE
    		LOG_MSG();
    	END_IF*)
    	(*########################################################################*)

    10..12:	(* ------ Daten aus buffer auslesen und optional löschen ------ *)
    		(* 10 = nur lesen / 11 = löschen nach lesen / 12 = lesen und löschen *)
    	IF DATA.D_MODE <> 11 THEN
    		IF DATA.BUF_COUNT = 0 THEN RETURN; END_IF
    		buf_totalsize := SIZEOF(DATA.BUF);
    		DATA._GetEnd := DATA._First;(* index des ältesten eintrags merken *)
    		mode_last := DATA.D_MODE;
    	
    		(* Header aus Buffer lesen *)
    		n1 := 0;
    		tmp_dw := 0;
    		REPEAT
    			n2 := MIN(HeaderSize - n1, buf_totalsize - DATA._GetEnd);
    			FOR n := 1 TO n2 DO
    				tmp_dw := ROL(tmp_dw,8) OR BYTE_TO_DWORD(DATA.BUF[DATA._GetEnd]);
    				DATA._GetEnd := DATA._GetEnd + 1;
    			END_FOR
    			IF DATA._GetEnd >= buf_totalsize THEN
    				DATA._GetEnd := 0;
    			END_IF
    			n1 := n1 + n2;
    		UNTIL n1 >= HeaderSize
    		END_REPEAT
    	
    		DATA._GetStart := DATA._GetEnd;
    		cnt := DWORD_TO_UINT(tmp_dw AND 16#0000_FFFF);
    		DATA.D_SIZE := cnt;
    		DATA.D_HEAD := DWORD_TO_WORD(SHR(tmp_dw,16));
    	
    		x := WORD_TO_BYTE(DATA.D_HEAD); (* nur rechtes byte auswerten *)
    		CASE x OF
    		01:	pTmp := ADR(DATA.D_STRING); (* String verarbeiten *)
    		02:	pTmp := ADR(DATA.D_REAL); (* Real verarbeiten *)
    		03:	pTmp := ADR(DATA.D_DWORD); (* DWORD verarbeiten *)
    		END_CASE
    	
    		(* Daten aus Buffer lesen *)
    		n1 := 0;
    		REPEAT
    			n2 := MIN(cnt - n1, buf_totalsize - DATA._GetEnd);
    			FOR n := 1 TO n2 DO
    				pTmp := DATA.BUF[DATA._GetEnd];
    				pTmp := pTmp + 1;
    				DATA._GetEnd := DATA._GetEnd + 1;
    			END_FOR
    			IF DATA._GetEnd >= buf_totalsize THEN
    				DATA._GetEnd := 0;
    			END_IF
    			n1 := n1 + n2;
    		UNTIL n1 >= cnt
    		END_REPEAT
    		IF x = 1 THEN
    			pTmp := 0; (* String terminieren *)
    		END_IF
    		DATA.D_MODE := 0;
    	
    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'RP: READ /HEAD ~1 / SIZE ~2 / cnt ~3 / >~4<';
    			LOG_CL.PRINTF[1] := DWORD_TO_STRH(DATA.D_HEAD);
    			LOG_CL.PRINTF[2] := UINT_TO_STRING(cnt);
    			LOG_CL.PRINTF[3] := UINT_TO_STRING(DATA.BUF_COUNT);
    			CASE x OF
    			01:	LOG_CL.PRINTF[4] := DATA.D_STRING;
    			02:	LOG_CL.PRINTF[4] := REAL_TO_STRING(DATA.D_REAL);
    			03:	LOG_CL.PRINTF[4] := DWORD_TO_STRH(DATA.D_DWORD);
    			ELSE
    				LOG_CL.PRINTF[4] := '';
    			END_CASE
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)
    	END_IF

    	IF (mode_last = 10 AND DATA.D_MODE = 11) OR (mode_last = 12 AND DATA.D_MODE = 0) THEN (* löschen nur direkt nach lesen möglich *)
    		mode_last := DATA.D_MODE;
    		DATA.BUF_SIZE := DATA.BUF_SIZE - cnt - HeaderSize;
    		DATA.BUF_COUNT := DATA.BUF_COUNT - 1;
    		DATA._First := DATA._GetEnd;
    		DATA.BUF_USED := UINT_TO_USINT(100 * DATA.BUF_SIZE / SIZEOF(DATA.BUF)); (* benützer Speicher in % *)
    		DATA.D_MODE := 0;

    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'RP: DEL /HEAD ~1 / SIZE ~2 / cnt ~3 / >~4<';
    			LOG_CL.PRINTF[1] := DWORD_TO_STRH(DATA.D_HEAD);
    			LOG_CL.PRINTF[2] := UINT_TO_STRING(cnt);
    			LOG_CL.PRINTF[3] := UINT_TO_STRING(DATA.BUF_COUNT);
    			CASE x OF
    			01:	LOG_CL.PRINTF[4] := DATA.D_STRING;
    			02:	LOG_CL.PRINTF[4] := REAL_TO_STRING(DATA.D_REAL);
    			03:	LOG_CL.PRINTF[4] := DWORD_TO_STRH(DATA.D_DWORD);
    			ELSE
    				LOG_CL.PRINTF[4] := '';
    			END_CASE
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)
    	END_IF

    99:	(* Buffer reset - alles löschen *)
    	DATA._First := 0;
    	DATA._Last := 0;
    	DATA._GetStart := 0;
    	DATA._GetEnd := 0;
    	DATA.BUF_COUNT := 0;
    	DATA.BUF_SIZE := 0;
    	DATA.BUF_USED := 0;
    	DATA.D_STRING := '';
    	DATA.D_DWORD := 0;
    	DATA.D_REAL := 0.0;
    	DATA.D_HEAD := 0;
    	DATA.D_MODE := 0;
    	DATA.D_SIZE := 0;
    	mode_last := 0;
    END_CASE

    (* höchsten Auslastungswert speichern *)
    IF DATA.BUF_USED > DATA.BUF_USED_MAX THEN
    	DATA.BUF_USED_MAX := DATA.BUF_USED;
    END_IF

    (* revision history
    ks	01. jan. 2011	rev 1.0
    	original version
    ks	25. jul. 2011	rev 1.1
    	neuen MODE 12 hinzugefügt
    ks	03. Sep. 2015	rev 1.2
    	Auslastungsüberwachung hinzugefügt
    ks	21. mar. 2016	rev 1.3
    	D_SIZE info hinzugefügt
    	Buffer size auf 8192 vergroessert
    *)
END_FUNCTION_BLOCK
