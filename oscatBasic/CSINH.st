FUNCTION CSINH
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=90*)
    CSINH.re := sinH(X.re) * COS(X.im);
    CSINH.im := cosH(X.re) * SIN(X.im);


    (* revision history
    hm	21. feb 2008	rev 1.0
    	original version

    *)
END_FUNCTION