FUNCTION_BLOCK TOGGLE
    IF rst THEN
    	q := 0;
    ELSIF clk AND NOT edge THEN
    	Q := NOT Q;
    END_IF
    edge := clk;

    (* revision history

    hm	13.9.2007		rev 1.0
    	original version

    hm	30. oct. 2008	rev 1.1
    	deleted unnecessary init

    *)




END_FUNCTION_BLOCK