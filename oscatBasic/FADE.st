FUNCTION_BLOCK FADE
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=276*)
    rmx(rst := rst AND NOT F, set := rst AND F, pt := TF, up := F);
    Y := (in2 - In1) / 65535.0 * WORD_TO_REAL(rmx.out) + in1;


    (* code for rev 1.1
    IF rst THEN
    	rmx(set := F, rst := NOT F);
    ELSIF F AND (NOT rmx.high) THEN
    	rmx(PT := TF, UP := TRUE, e := TRUE, rst := FALSE, set := FALSE);
    ELSIF (NOT F) AND (NOT rmx.low) THEN
    	rmx(PT := TF, UP := FALSE, e := TRUE, rst := FALSE, set := FALSE);
    ELSE
    	rmx(e := FALSE, rst := FALSE, set := FALSE);
    END_IF
    Y := (WORD_TO_REAL(rmx.out) * in1 + WORD_TO_REAL(FF - rmx.out) * IN2) / FF;
    *)


    (* revision history
    hm	26. dec 2007	rev 1.0
    	original version

    hm	18. oct. 2008	rev 1.1
    	improved performance
    	changed calls for rmp_w because rmp_w has chaged

    hm	17. dec. 2008	rev 1.2
    	function of input f was inverted

    hm	24. jan. 2009	rev 1.3
    	delted unused var FF
    *)
END_FUNCTION_BLOCK