FUNCTION BIT_LOAD_W2
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=213*)
    IF D THEN
    	BIT_LOAD_W2 := ROL(SHR(WORD#65535, 16 - N) OR ROR(I, P), P);
    ELSE
    	BIT_LOAD_W2 := ROL(SHL(WORD#65535, N) AND ROR(I, P), P);
    END_IF



    (* revision history
    hm	18. oct. 2008	rev 1.0
    	original version


    *)

END_FUNCTION
