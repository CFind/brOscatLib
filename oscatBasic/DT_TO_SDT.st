FUNCTION DT_TO_SDT
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=122*)
    tmp := DT_TO_DATE(dti);
    tdt := DT_TO_DWORD(dti) - DATE_TO_DWORD(tmp);
    DT_TO_SDT.YEAR := YEAR_OF_DATE(tmp);
    DT_TO_SDT.MONTH := MONTH_OF_DATE(tmp);
    DT_TO_SDT.DAY := DAY_OF_MONTH(tmp);
    DT_TO_SDT.WEEKDAY := DAY_OF_WEEK(tmp);
    DT_TO_SDT.SECOND := DWORD_TO_INT(tdt MOD 60);
    DT_TO_SDT.MINUTE := DWORD_TO_INT((tdt / 60) MOD 60);
    DT_TO_SDT.HOUR := DWORD_TO_INT(tdt / 3600);

    (* revision history

    hm 18. oct. 2008	rev 1.0
    	original version

    *)
END_FUNCTION