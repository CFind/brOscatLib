FUNCTION_BLOCK TIMER_P4
    (*http://www.oscat.de/images/OSCATBuilding/oscat_building100_en.pdf#page=65*)
    (* for performance reasons we only execute the code at the beginning of a new second *)

    IF RST THEN
    	(* reset all events to last active on 1.1.1970 *)
    	last_execute := DT#1970-1-1-00:00;
    	FOR pos := 0 TO array_max DO
    		IF (PROG[pos].channel >= OFS) AND (PROG[pos].channel < (OFS + 4)) THEN PROG[pos].LAST := last_execute; END_IF
    	END_FOR

    	(* reset all set markers and logic masks *)
    	FOR pos := 0 TO channel_max DO
    		qs[pos] := FALSE;
    	END_FOR

    (* normal operation *)
    ELSIF DTIME <> last_execute THEN
    	(* save the actual second for next execution test *)
    	last_execute := DTIME;

    	(* calculate dt for the start of the day to be used in comparisons *)
    	day_start := DATE_TO_DT(DT_TO_DATE(DTIME));

    	(* set all qn to FALSE *)
    	FOR pos := 0 TO channel_max DO qn[pos] := FALSE; END_FOR

    	(* search the array PROG for timer events *)
    	FOR pos := 0 TO array_max DO
    		event := PROG[pos];
    		channel := event.channel - OFS;
    		IF (event.TYP > 0) AND (channel >= 0) AND (channel <= channel_max) THEN
    			ma[channel] := event.LAND;
    			mo[channel] := event.LOR;
    			CASE event.TYP OF
    				1:	(* daily event *)
    					start := day_start + TOD_TO_TIME(event.start);
    					qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;

    				2: 	(* event by selected weekdays *)
    					IF (SHR(BYTE#128, DAY_OF_WEEK(DT_TO_DATE(DTIME))) AND event.DAY) > 0 THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				3:	(* event every N days *)
    					IF current_day MOD event.DAY = 0 THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				10:	(* weekly event exactly once a week the weekday is specified in day, 1= mo *)
    					IF DAY_OF_WEEK(DT_TO_DATE(DTIME)) = BYTE_TO_INT(event.DAY) THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				20:	(* monthly event *)
    					IF DAY_OF_MONTH(DT_TO_DATE(DTIME)) = BYTE_TO_INT(event.DAY) THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				21:	(* event on last day of month *)
    					IF DT_TO_DATE(DTIME) = MONTH_END(DT_TO_DATE(DTIME)) THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				30:	(* yearly event on a specific day specified in day *)
    					IF DAY_OF_YEAR(DT_TO_DATE(DTIME)) = BYTE_TO_INT(event.DAY) THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				31:	(* event on last day of year *)
    					IF DT_TO_DATE(DTIME) = YEAR_END(YEAR_OF_DATE(DT_TO_DATE(DTIME))) THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				40:	(* event on leap days *)
    					IF LEAP_DAY(DT_TO_DATE(DTIME)) THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				41: (* event on holidays *)
    					IF HOLY THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				42: (* event on holidays and weekends *)
    					IF (HOLY OR (DAY_OF_WEEK(DT_TO_DATE(DTIME)) = 6) OR (DAY_OF_WEEK(DT_TO_DATE(DTIME)) = 7)) THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				43:	(* event on workdays mo-FR and no holiday *)
    					IF DAY_OF_WEEK(DT_TO_DATE(DTIME)) < 6 THEN
    						start := day_start + TOD_TO_TIME(event.start);
    						qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;
    					END_IF

    				50: (* event after reference time *)
    					CASE PROG[pos].DAY OF
    						0:	tx := TREF_0;
    						1:	tx := TREF_1;
    					ELSE
    						tx := TOD#00:00;
    					END_CASE
    					start := day_start + TOD_TO_TIME(tx) + TOD_TO_TIME(event.start);
    					qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;

    				51:	(* event before reference time *)
    					CASE PROG[pos].DAY OF
    						0:	tx := TREF_0;
    						1:	tx := TREF_1;
    					ELSE
    						tx := TOD#00:00;
    					END_CASE
    					start := day_start + TOD_TO_TIME(tx) - TOD_TO_TIME(event.start);
    					qn[channel] := DTIME >= start AND DTIME <= start + event.DURATION;

    				52 : (* set output at specific time + offset  *)
    					CASE PROG[pos].DAY OF
    						0:	tx := TREF_0;
    						1:	tx := TREF_1;
    					ELSE
    						tx := TOD#00:00;
    					END_CASE
    					start := day_start + TOD_TO_TIME(tx) + TOD_TO_TIME(event.start);
    					IF DTIME >= start AND day_start > event.LAST THEN
    						qs[channel] := TRUE;
    						PROG[pos].LAST := day_start;
    					END_IF

    				53 : (* reset output at specific time + offset *)
    					CASE PROG[pos].DAY OF
    						0:	tx := TREF_0;
    						1:	tx := TREF_1;
    					ELSE
    						tx := TOD#00:00;
    					END_CASE
    					start := day_start + TOD_TO_TIME(tx) + TOD_TO_TIME(event.start);
    					IF DTIME >= start AND day_start > event.LAST THEN
    						qs[channel] := FALSE;
    						PROG[pos].LAST := day_start;
    					END_IF

    				54 : (* set output at specific time - offset  *)
    					CASE PROG[pos].DAY OF
    						0:	tx := TREF_0;
    						1:	tx := TREF_1;
    					ELSE
    						tx := TOD#00:00;
    					END_CASE
    					start := day_start + TOD_TO_TIME(tx) - TOD_TO_TIME(event.start);
    					IF DTIME >= start AND day_start > event.LAST THEN
    						qs[channel] := TRUE;
    						PROG[pos].LAST := day_start;
    					END_IF

    				55 : (* reset output at specific time - offset *)
    					CASE PROG[pos].DAY OF
    						0:	tx := TREF_0;
    						1:	tx := TREF_1;
    					ELSE
    						tx := TOD#00:00;
    					END_CASE
    					start := day_start + TOD_TO_TIME(tx) - TOD_TO_TIME(event.start);
    					IF DTIME >= start AND day_start > event.LAST THEN
    						qs[channel] := FALSE;
    						PROG[pos].LAST := day_start;
    					END_IF
    			END_CASE
    		END_IF
    	END_FOR
    END_IF

    (* prepare the logical input mask *)
    mask := 255;
    mask.0 := L0;
    mask.1 := L1;
    mask.2 := L2;
    mask.3 := L3;

    (* set the outputs *)
    Q0 := ENQ AND ((qn[0] OR qs[0]) AND ((ma[0] AND mask) = ma[0]) OR ((mo[0] AND mask) > 0) OR (MAN AND MI.0));
    Q1 := ENQ AND ((qn[1] OR qs[1]) AND ((ma[1] AND mask) = ma[1]) OR ((mo[1] AND mask) > 1) OR (MAN AND MI.1));
    Q2 := ENQ AND ((qn[2] OR qs[2]) AND ((ma[2] AND mask) = ma[2]) OR ((mo[2] AND mask) > 2) OR (MAN AND MI.2));
    Q3 := ENQ AND ((qn[3] OR qs[3]) AND ((ma[3] AND mask) = ma[3]) OR ((mo[3] AND mask) > 3) OR (MAN AND MI.3));

    (* set STATUS *)
    IF NOT ENQ THEN
    	STATUS := 100;
    ELSIF MAN THEN
    	STATUS := 101;
    ELSE
    	STATUS := 102;
    END_IF



    (* revision history
    hm	17. jun 2008	rev 1.0
    	original version

    hm	9. oct. 2008	rev 1.1
    	changed function year to year_of_date
    	changed function weekday to day_of_week
    	changed structure of program to be more efficient
    	changed input DIS to ENQ

    hm	18. oct. 2008	rev 1.2
    	changed type of input OFS from int to byte
    	added typecasts to avoid warnings

    hm	28. feb. 2009	rev 1.3
    	array was not correctly initialized

    hm	26. jan 2011	rev 1.4
    	changed code to allow events over midnight
    *)

END_FUNCTION_BLOCK
