FUNCTION ARRAY_MAX
    stop := (size -SIZEOF(pt)) / SIZEOF(pt);
    array_max := pt^[0];
    FOR i := 1 TO stop DO
    	IF pt^[i] > array_max THEN array_max := pt^[i]; END_IF
    END_FOR

    (* revision history
    hm	2. oct 2006		rev 1.0
    	original version

    hm	16. mar. 2008	rev 1.1
    	changed input size to uint
    *)
END_FUNCTION