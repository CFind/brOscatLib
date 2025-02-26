FUNCTION_BLOCK DLOG_REAL
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=51*)
    CASE X.ADD_COM OF

    01:	(* ADD INFO *)
    	X.ID_MAX := X.ID_MAX + USINT#1;
    	id := WORD#16#0201; (* Quelltype REAL , Zieltype STRING *)
    02:	(* ADD HEADER *)
    	X.UCB.D_STRING := COLUMN;
    	X.UCB.D_HEAD := id;
    	X.UCB.D_MODE := 1;
    	UCB(DATA:=X.UCB); (* Daten eintragen *)
    03:	(* ADD DATA *)
    	X.UCB.D_STRING := REAL_TO_STRF(IN:=value_last,N:=N,D:=D);
    	X.UCB.D_HEAD := id;
    	X.UCB.D_MODE := 1;
    	UCB(DATA:=X.UCB); (* Daten eintragen *)
    	delta_last := value_last;
    04:	(* ADD DATA REQ *)
    	IF DELTA <> 0.0 THEN
    		IF VALUE <= (delta_last - DELTA) OR VALUE >= (delta_last + DELTA) THEN
    			X.ADD_DATA_REQ := TRUE;
    			delta_last := VALUE;
    		END_IF
    	END_IF
    END_CASE
    value_last := VALUE;

    (* revision history
    ks	01. jan. 2011	rev 1.0
    	original version

    ks	17. may. 2011	rev 1.1
    	DELTA Funktion integriert

    ks	25. july.   2011	rev 1.2
    	neue head information

    ks	19. apr.   2012	rev 1.3
    	code neu überarbeitet
    *)
END_FUNCTION_BLOCK
