FUNCTION MONTH_BEGIN
    MONTH_BEGIN := DWORD_TO_DATE(DATE_TO_DWORD(idate) - INT_TO_DWORD(DAY_OF_MONTH(idate) - 1) * 86400);

    (* revision history
    hm	15. jun. 2008	rev 1.0
    	original version	

    *)
END_FUNCTION