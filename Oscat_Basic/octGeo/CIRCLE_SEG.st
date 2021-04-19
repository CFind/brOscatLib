FUNCTION CIRCLE_SEG
    IF RX > 0.0 THEN
    	CIRCLE_SEG := 2.0 * ACOS(1.0 - LIMIT(0.0, HX / RX, 2.0));
    	CIRCLE_SEG := (CIRCLE_SEG - SIN(CIRCLE_SEG)) *RX * RX / 2.0;
    END_IF


    (* revision histroy
    hm	10. mar 2010	rev 1.0
    	original version

    *)
END_FUNCTION