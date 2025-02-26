FUNCTION_BLOCK METER_STAT
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=345*)
    IF RST THEN
    	LAST_DAY := 0.0;
    	CURRENT_DAY := 0.0;
    	Day_Start := IN;
    	LAST_WEEK := 0.0;
    	CURRENT_WEEK := 0.0;
    	Week_Start := IN;
    	LAST_MONTH := 0.0;
    	CURRENT_MONTH := 0.0;
    	Month_Start := IN;
    	LAST_YEAR := 0.0;
    	CURRENT_YEAR := 0.0;
    	Year_Start := IN;
    ELSE
    	CURRENT_DAY := IN - Day_Start;
    	CURRENT_WEEK := IN - Week_Start;
    	CURRENT_MONTH := IN - Month_Start;
    	CURRENT_YEAR := IN - Year_Start;
    END_IF

    IF YEAR_OF_DATE(DI) > YEAR_OF_DATE(last_run) THEN
    	(* a new year has started *)
    	LAST_YEAR := CURRENT_YEAR;
    	CURRENT_YEAR := 0.0;
    	Year_Start := IN;
    	LAST_MONTH := CURRENT_MONTH;
    	CURRENT_MONTH := 0.0;
    	Month_Start := IN;
    	LAST_DAY := CURRENT_DAY;
    	CURRENT_DAY := 0.0;
    	Day_Start := IN;
    ELSIF MONTH_OF_DATE(DI) > MONTH_OF_DATE(last_run) THEN
    	(* a new month has started, january is alrerady done by year change *)
    	LAST_MONTH := CURRENT_MONTH;
    	CURRENT_MONTH := 0.0;
    	Month_Start := IN;
    	LAST_DAY := CURRENT_DAY;
    	CURRENT_DAY := 0.0;
    	Day_Start := IN;
    ELSIF DAY_OF_YEAR(DI) > DAY_OF_YEAR(last_run) THEN
    	(* day has chaged, first day of year and first day of month has already been taken care of *)
    	LAST_DAY := CURRENT_DAY;
    	CURRENT_DAY := 0.0;
    	Day_Start := IN;
    END_IF
    IF DAY_OF_WEEK(DI) < DAY_OF_WEEK(last_run) THEN
    	(* a new week has started *)
    	LAST_WEEK := CURRENT_WEEK;
    	CURRENT_WEEK := 0.0;
    	Week_Start := IN;
    END_IF
    last_run := DI;

    (* revision history
    hm	16. sep. 2007	rev 1.0
    	original version

    hm	7. oct. 2008	rev 1.1
    	changed function year_to_year_of_date
    	changed function month to month_of_date
    	changed function weekday to day_of_week

    hm	11. mar. 2009	rev 1.2
    	changed real constants to use dot syntax

    hm	18. jul. 2009	rev 1.3
    	changes all outputs to be I/O
    *)

END_FUNCTION_BLOCK
