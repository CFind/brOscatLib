FUNCTION_BLOCK MB_VMAP
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=118*)
    IF init = FALSE THEN
    	init := TRUE;
    	IF VMAP[1].FC = DWORD#0 THEN
    		VMAP[1].FC := DWORD#16#FFFF_FFFF;
    		VMAP[1].V_ADR := 0;
    		VMAP[1].V_SIZE := 256;
    		VMAP[1].P_ADR := 0;
    	END_IF
    END_IF

    ERROR := BYTE#02; (* ILLEGAL DATA ADDRESS *)
    mask := SHL(DWORD#1,FC);

    IF (mask AND DWORD#2#00000000_01000000_00000000_01100000) <> DWORD#0 THEN (* FC 5,6,22 *)
    	V_CNT := 1;
    ELSIF V_CNT = 0 THEN
    	RETURN;
    END_IF

    FOR i := 1 TO 10 DO
    	vopt := VMAP[i].FC; 
    	IF (vopt AND mask) <> DWORD#0 THEN
    		vadr := VMAP[i].V_ADR;
    		vsize := VMAP[i].V_SIZE;
    		padr := VMAP[i].P_ADR;

    		IF (mask AND DWORD#2#00000000_00000000_10000000_00100110) <> DWORD#0 THEN (* FC 1,2,5,15 für Bit-Access *)
    			i_tmp := WORD_TO_INT(SHR(INT_TO_WORD(V_ADR + V_CNT -1),4))+1;
    			IF i_tmp <= SIZE AND i_tmp <= vsize THEN
    				w_tmp := INT_TO_WORD(V_ADR);
    				P_ADR := WORD_TO_INT(SHR(w_tmp,4)) + padr; 
    				P_BIT := WORD_TO_INT(w_tmp AND WORD#16#000F);
    				ERROR := BYTE#0;
    				EXIT;
    			END_IF
    		ELSIF (mask AND DWORD#2#00000000_11000001_00000000_01011000) <> DWORD#0 THEN (* FC 3,4,6,16,22,23 für Register-Access *)
    			IF V_ADR >= vadr AND V_ADR + V_CNT <= vadr + vsize THEN (* gültiger virtueller bereich *)
    				P_ADR := V_ADR - vadr + padr; (* reale Adresse berechnen *)
    				IF P_ADR + V_CNT <= SIZE THEN (* bereichsueberschreitung ? *)
    					ERROR := BYTE#0;
    					EXIT;
    				END_IF
    			END_IF
    		ELSE
    			ERROR := BYTE#01; (* ILLEGAL FUNCTION *)
    			RETURN;
    		END_IF
    	END_IF
    END_FOR

    IF ERROR = BYTE#0 THEN
    	IF (mask AND DWORD#2#00000000_11000001_10000000_01100000) <> DWORD#0 THEN (* FC 5,6,15,16,22,23 Schreib-zugriff *)
    		VMAP[i].TIME_OUT := T#1ms;
    	END_IF
    END_IF

    (* revision history
    ks	05. jan. 2009	rev 1.0
    	original version

    ks	20. oct. 2009	rev 1.1
    	fehlerkorrektur in bitmaske

    *)
END_FUNCTION_BLOCK
