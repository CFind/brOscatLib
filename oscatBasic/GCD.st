FUNCTION GCD
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=53*)
    IF A = 0 THEN
    	GCD := DINT_TO_INT(ABS(B));
    ELSIF B = 0 THEN
    	GCD := DINT_TO_INT(ABS(A));
    ELSE
    	A := ABS(A);
    	B := ABS(B);
    	GCD := 1;
    	WHILE NOT(A.0 OR B.0) DO
    		A := SHR(A,1);
    		B := SHR(B,1);
    		GCD := SHL(GCD,1);
    	END_WHILE
    	WHILE A > 0 DO
    		IF NOT(A.0) THEN A := SHR(A,1);
    		ELSIF NOT(B.0) THEN B := SHR(B,1);
    		ELSE
    			t:= SHR(ABS(A-B),1);
    			IF A < B THEN B := t; ELSE A := t; END_IF
    		END_IF
    	END_WHILE
    	GCD := GCD * DINT_TO_INT(B);
    END_IF


    (* revision history
    hm	19. jan. 2011	rev 1.0
    	original version

    *)
END_FUNCTION
