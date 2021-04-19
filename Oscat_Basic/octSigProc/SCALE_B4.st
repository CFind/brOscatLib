FUNCTION SCALE_B4
    SCALE_B4 := 	(((in1_max - in1_min)* in1 + (in2_max - in2_min)* in2 + (in3_max - in3_min)* in3 + (in4_max - in4_min)* in4)* 0.003921569 + in1_min + in2_min + in3_min + in4_min) * K + O;


    (* revision History
    hm 19.1.2007		rev 1.1
    	changed outputs to real to avoid overflow of integer
    	added offset for better cascading of scale functions
    	changed from fb to function

    hm	6. jan 2008		rev 1.2
    	improved performance

    hm	26. oct. 2008	rev 1.3
    	optimized code

    hm	3. nov. 2008	rev 1.4
    	used wrong factor in formula

    *)
END_FUNCTION