FUNCTION_BLOCK TEMPERATURE
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=374*)
    YK := K + (C + 273.15) + (F + 459.67) * 0.555555555555 + (RE * 1.25 + 273.15) + (RA * 0.555555555555);
    YC := YK -273.15;
    YF := YK * 1.8 - 459.67;
    YRE := (YK - 273.15) * 0.8;
    YRA := YK * 1.8;


    (* revision history
    hm	21. feb. 2008	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK
