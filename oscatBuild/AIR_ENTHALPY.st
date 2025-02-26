FUNCTION AIR_ENTHALPY
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=427*)
    AIR_ENTHALPY := CPL * T + (CW * T + LH) * DEW_CON(RH,T);

    (* revision history

    hm	31.10.2007	rev 1.0
    	original version

    hm	2.11.2007		rev 1.1
    	deleted unused variable RF

    hm	2.12.2007		rev 1.2
    	changed code for better performance
    *)


END_FUNCTION
