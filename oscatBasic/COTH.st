FUNCTION COTH
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=45*)
    IF X > 20.0 THEN
    	COTH :=1.0;
    ELSIF X < -20.0 THEN
    	COTH := -1.0;
    ELSE
    	COTH := 1.0 + 2.0 / (EXP(X * 2.0) - 1.0);
    END_IF


    (* revision histroy
    hm		12.1.2007	rev 1.0
    	original version

    hm	1.12.2007		rev 1.1
    	changed code to improve performance

    hm	8. jan 2008	rev 1.2
    	further improvement in performance

    hm	10. mar 2008	rev 1.3
    	extended range of valid inputs to +/- INV
    	changed formula for better accuracy

    hm	10. mar. 2009	rev 1.4
    	real constants updated to new systax using dot
    *)
END_FUNCTION
