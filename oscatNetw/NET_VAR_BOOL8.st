FUNCTION_BLOCK NET_VAR_BOOL8
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=200*)
    IF NOT init THEN
    	init := TRUE;
    	X.ID_MAX := X.ID_MAX + USINT#1;
    	ID := USINT_TO_BYTE(X.ID_MAX);
    END_IF

    IF X.STATE > BYTE#0 AND X.ERROR_ID = BYTE#0 THEN
    	index := X.index; (* PCWORX Workaround *)
    	IF INT_TO_UINT(index + 3) > X.BUF_SIZE THEN
    		X.ERROR_ID := ID;
    	ELSE
    		IF X.STATE = BYTE#1 THEN (* Daten schreiben *)
    			X.S_BUF.BUFFER[index] := ID; (* ID *)
    			index := index + 1;
    			X.S_BUF.BUFFER[index] := BYTE#4; (* TYPE BOOL8 *)
    			index := index + 1;
    			X.S_BUF.BUFFER[index] := BYTE_OF_BIT(IN1,IN2,IN3,IN4,IN5,IN6,IN7,IN8);
    			index := index + 1;

    		ELSIF X.STATE = BYTE#2 THEN (* Daten lesen *)
    			index2 := index + 1; (* PCWORX Workaround *)
    			IF X.R_BUF.BUFFER[index] <> ID OR X.R_BUF.BUFFER[index2] <> BYTE#4 THEN
    				X.ERROR_ID := ID;
    			ELSE
    				index := index + 2;
    				BYTE_TO_BITS(IN:=X.R_BUF.BUFFER[index]);
    				OUT1 := BYTE_TO_BITS.B0;
    				OUT2 := BYTE_TO_BITS.B1;
    				OUT3 := BYTE_TO_BITS.B2;
    				OUT4 := BYTE_TO_BITS.B3;
    				OUT5 := BYTE_TO_BITS.B4;
    				OUT6 := BYTE_TO_BITS.B5;
    				OUT7 := BYTE_TO_BITS.B6;
    				OUT8 := BYTE_TO_BITS.B7;
    				index := index + 1;
    			END_IF
    		END_IF
    		X.index := index;
    	END_IF
    END_IF

    (* revision history
    ks	15.may. 2011	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
