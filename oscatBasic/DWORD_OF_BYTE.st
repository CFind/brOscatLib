FUNCTION DWORD_OF_BYTE
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=225*)
    DWORD_OF_BYTE := SHL(SHL(SHL(BYTE_TO_DWORD(B3),8) OR BYTE_TO_DWORD(B2),8) OR BYTE_TO_DWORD(B1),8) OR BYTE_TO_DWORD(B0);


    (* revision history
    hm	24. jan 2007	rev 1.0
    	original version

    hm 2. jan 2008	rev 1.1
    	inproved performance

    hm	23. apr. 2008	rev 1.2
    	reverse order of inputs to be more logical

    hm	18. jul. 2009	rev 1.3
    	added type conversions for compatibility reasons
    *)
END_FUNCTION
