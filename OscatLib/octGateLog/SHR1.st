FUNCTION SHR1
    SHR1 := SHL(temp,32-N) OR SHR(IN,N);

    (* revision history
    hm	14.9.2007		rev 1.0
    	original version

    hm	27. dec 2007	rev 1.1
    	changed code for better performance

    *)
END_FUNCTION