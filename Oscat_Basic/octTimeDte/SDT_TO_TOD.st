FUNCTION SDT_TO_TOD
    SDT_TO_TOD := DWORD_TO_TOD(INT_TO_DWORD(DTI.HOUR) * 3600000 + INT_TO_DWORD(DTI.MINUTE) * 60000 + INT_TO_DWORD(DTI.SECOND) * 1000 + INT_TO_DWORD(DTI.MS));



    (* revision history

    hm 18. oct. 2008	rev 1.0
    	original version

    hm	16. nov. 2008	rev 1.1
    	added typecasts to avoid warnings
    *)
END_FUNCTION