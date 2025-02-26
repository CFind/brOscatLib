FUNCTION GAUSS
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=52*)
    temp := X - U;
    si_inv := 1.0  / SI;
    GAUSS := EXP(temp * temp * si_inv * si_inv * - 0.5) * 0.39894228 * si_inv;



    (* revision hisdtory
    hm	6. apr. 2008	rev 1.0
    	original version

    hm	27. oct. 2008	rev 1.1
    	optimized performance	

    hm	10. mar. 2009	rev 1.2
    	real constants updated to new systax using dot

    *)
END_FUNCTION
