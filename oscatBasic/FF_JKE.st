FUNCTION_BLOCK FF_JKE
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=241*)
    IF RST OR SET THEN
    	Q := NOT RST;
    ELSIF CLK AND NOT edge_ THEN
    	IF J XOR K THEN Q := J;
    	ELSE Q := K XOR Q;
    	END_IF
    END_IF
    edge_ := CLK;

    (* revision history
    hm	4. aug 2006		rev 1.0
    	original version

    hm	27. dec 2007	rev 1.1
    	changed code for better performance

    hm	30. oct. 2008	rev 1.2
    	optimized performance
    *)
END_FUNCTION_BLOCK
