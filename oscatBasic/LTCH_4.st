FUNCTION_BLOCK LTCH_4
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=246*)
    (* as long as L is true, the latch is transparent and and change of D is transferred to Q *)
    (* of course only when there is no asynchronous reset *)
    IF RST THEN			(* if asynchronous reset then Q=0 *)
    	Q0 := FALSE;
    	Q1 := FALSE;
    	Q2 := FALSE;
    	Q3 := FALSE;
    ELSIF L THEN			(* latch is transparent *)
    	Q0 := D0;
    	Q1 := D1;
    	Q2 := D2;
    	Q3 := D3;
    END_IF

    (* revision history
    hm	4. aug 2006	rev 1.0
    	original version

    hm	27. dec 2007	rev 1.1
    	changed code for better performance

    hm	30. oct. 2008	rev 1.2
    	deleted unnecessary init with 0

    hm	14. mar. 2009	rev 1.3
    	removed double assignments

    *)
END_FUNCTION_BLOCK
