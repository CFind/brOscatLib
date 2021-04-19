FUNCTION RES_NTC
    RES_NTC := RN * EXP(B * (1.0 / (T+273.15) - 0.00335401643468053));



    (* revision history

    hm 30. dec. 2008	rev 1.0
    	original version

    hm	11. mar. 2009	rev 1.1
    	changed real constants to use dot syntax

    *)
END_FUNCTION