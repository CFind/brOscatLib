FUNCTION ASINH
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=40*)
    ASINH := LN(SQRT(X * X + 1.0)+X);

    (* revision history
    hm		12 jan 2007	rev 1.0
    	original version

    hm		2. dec 2007	rev 1.1
    	changed code for better performance

    hm		16.3. 2007		rev 1.2
    	changed sequence of calculations to improve performance

    hm	10. mar. 2009		rev 1.3
    	real constants updated to new systax using dot

    *)
END_FUNCTION
