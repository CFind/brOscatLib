FUNCTION_BLOCK PRINT_SF
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=121*)
    IF LEN(STR) > 0 THEN
    	run := TRUE;

    	WHILE (run) DO
    		pos := FIND(STR,src);
    		PRINTF_DATA[10] := '';

    		IF pos = 0 THEN
    			run:= FALSE;
    		ELSE
    			c := CODE(STR:=STR,pos:=pos + 1);
    			IF ISC_NUM(INT_TO_BYTE(c)) THEN
    				c := c - 48; (* notwendig weil innerhalb einer indexangabe nur eine var stehen darf *)
    				PRINTF_DATA[10] := PRINTF_DATA[c]; (* Kommando 1-9 ergibt Parameterindex 1-9 *)
    				(* Parameter gegen Text tauschen *)
    			END_IF
    			IF LEN(PRINTF_DATA[10]) + LEN(STR) > LOG_SIZE THEN
    				PRINTF_DATA[10] := '..';
    			END_IF
    			(* pcworx: aus und eingangsstring muss verschieden sein *)
    			PRINTF_DATA[11] := STR;
    			STR := REPLACE(PRINTF_DATA[11],PRINTF_DATA[10],2,pos);
    		END_IF
    	END_WHILE
    END_IF

    (* revision history

    ks	14. aug. 2009	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
