FUNCTION POLYNOM_INT
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=102*)
    (*make sure n is bound within the array size *)
    pts := MIN(pts, 5);

    (* this part is only to calculate the polynom parameters, which are then stores in the Y array
    	the array values, it is not needed during runtime, unless the parameters will change during runtime
    	the remaining code without this setup code can be used within a function to calculate specific functions
    	the content of the arrays is then used as constant values within the function *)

    FOR i := 1 TO pts DO
    	stop := i + 1;
       	FOR j := pts TO stop BY -1 DO
       		XY[j,1] := (XY[j,1] - XY[j-1,1]) / (XY[j,0] - XY[j-i,0]);
    	END_FOR
    END_FOR


    (* this part is the actual calculation *)
    POLYNOM_INT := 0.0;
    FOR i := pts TO 1 BY -1 DO
           POLYNOM_INT := POLYNOM_INT * (X - XY[i,0]) + XY[i,1];
    END_FOR


    (* revision history
    hm	8. okt 2007	rev 1.0
    	original version

    hm	17. dec 2007	rev 1.1
    	init makes no sense for a function

    hm	22. feb 2008	rev 1.2
    	improved performance

    hm	10. mar. 2009	rev 1.3
    	changed syntax of real constants to 0.0

    *)
END_FUNCTION