FUNCTION ATANH
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=41*)
    ATANH := LN((1.0 + X)/(1.0 - X)) * 0.5;


    (* revision history
    hm		12 jan 2007	rev 1.0
    	original version

    hm		5. jan 2008	rev 1.1
    	improved code for better performance

    hm	10. mar. 2009		rev 1.2
    	real constants updated to new systax using dot

    *)

END_FUNCTION
