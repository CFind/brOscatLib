FUNCTION_BLOCK TREND
    TU := X > last_X;
    TD := X < last_X;
    Q := TU OR TD;
    D := X - LAST_X;

    last_X := X;



    (* revision history
    hm	21. aug. 2009	rev 1.0
    	original version

    *)

END_FUNCTION_BLOCK