FUNCTION_BLOCK BASE64_ENCODE_STR
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=74*)
    CASE mode OF
    0:	IF RUN AND NOT run_last THEN
    		DONE := FALSE;
    		mode := 1;
    		end := LEN(STR1);
    		pos := 0;
    		STR2 := '';
    	END_IF
    1:
    	size1 := MIN(48,end - pos);
    	IF size1 > 0 THEN
    		_STRING_TO_BUFFER(STR:=MID(STR1, size1, pos + 1), pos:=0, PT:=ADR(buf1), SIZE:=SIZEOF(buf1));
    		BASE64_ENCODE_STREAM(buf1:=buf1 ,buf2:=buf2 ,size1:=size1 ,size2=>size2);
    		STR2 := CONCAT(STR2,BUFFER_TO_STRING(PT:=ADR(buf2), SIZE:=SIZEOF(buf2), START:=0, STOP:=size2 - 1));
    	ELSE
    		mode := 0;
    		DONE := TRUE;
    	END_IF
    	pos := pos + size1;
    END_CASE

    run_last := RUN;

    (* revision history

    ks	6. dec. 2009 rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
