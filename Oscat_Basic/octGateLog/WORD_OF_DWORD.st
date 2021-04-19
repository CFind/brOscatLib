FUNCTION WORD_OF_DWORD
    WORD_OF_DWORD := DWORD_TO_WORD(SHR(in,SHL(n,4)));

    (* revision history
    hm	17. jan 2007	rev 1.0
    	original version

    hm	2. jan 2008		rev 1.1
    	improved performance

    hm	30. oct. 2008	rev 1.2
    	improved performance
    *)

END_FUNCTION