FUNCTION_BLOCK DCF77
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=119*)
    (* if tp was set it should only be active for 1 cycle *)
    TP := FALSE;

    (* read system time *)
    t1 := DWORD_TO_TIME(T_PLC_MS());
    tx := t1 - last;

    IF rec XOR edge THEN
    	edge := rec;
    	IF NOT rec AND tx > t#1700ms AND tx < t#2000ms THEN
    		(* start condition reached *)
    		state := 0;
    		tp := NOT error;
    	ELSIF NOT rec AND tx > t#700ms AND tx < t#1000ms THEN
    		(* second switch detected *)
    		IF state < 58 THEN state := state +1; ELSE state := 0; END_IF
    	ELSIF rec AND tx  < t#120ms THEN
    		(* bit 0 detected  *)
    		bits[state] := 0;
    	ELSIF rec AND tx > t#120ms AND tx < t#250ms THEN
    		(* bit 1 detected *)
    		bits[state] := 1;
    	ELSE
    		(* error condition received signal is not valid *)
    		error := TRUE;
    		state := 0;
    	END_IF
    	last := last + tx;
    	IF rec AND state = 58 THEN
    		error := FALSE;

    		(* decode the bits and check for possible errors *)
    		IF bits[0] OR NOT (bits[17] XOR bits[18]) OR NOT bits[20] THEN error := TRUE; END_IF
    		(* decode minute *)
    		MINUTE := 0;
    		MINUTE.0 := bits[21];
    		MINUTE.1 := bits[22];
    		MINUTE.2 := bits[23];
    		MINUTE.3 := bits[24];
    		IF bits[25] THEN MINUTE := MINUTE + 10; END_IF
    		IF bits[26] THEN MINUTE := MINUTE + 20; END_IF
    		IF bits[27] THEN MINUTE := MINUTE + 40; END_IF
    		IF MINUTE > 59 OR (bits[21] XOR bits[22] XOR bits[23] XOR bits[24] XOR bits[25] XOR bits[26] XOR bits[27] XOR bits[28]) THEN error := TRUE; END_IF

    		(* decode hour *)
    		HOUR := 0;
    		HOUR.0 := bits[29];
    		HOUR.1 := bits[30];
    		HOUR.2 := bits[31];
    		HOUR.3 := bits[32];
    		IF bits[33] THEN HOUR := HOUR + 10; END_IF
    		IF bits[34] THEN HOUR := HOUR +20; END_IF
    		IF HOUR > 23 OR (bits[29] XOR bits[30] XOR bits[31] XOR bits[32] XOR bits[33] XOR bits[34] XOR bits[35]) THEN error := TRUE; END_IF

    		(* decode day of month *)
    		day := 0;
    		day.0 := bits[36];
    		day.1 := bits[37];
    		day.2 := bits[38];
    		day.3 := bits[39];
    		IF bits[40] THEN day := day + 10; END_IF
    		IF bits[41] THEN day := day + 20; END_IF
    		IF day > 31 THEN error := TRUE; END_IF

    		(* decode day of week *)
    		wday := 0;
    		wday.0 := bits[42];
    		wday.1 := bits[43];
    		wday.2 := bits[44];
    		IF wday > 7 OR wday < 1 THEN error := TRUE; END_IF

    		(* decode month *)
    		MONTH := 0;
    		MONTH.0 := bits[45];
    		MONTH.1 := bits[46];
    		MONTH.2 := bits[47];
    		MONTH.3 := bits[48];
    		IF bits[49] THEN MONTH := MONTH +10; END_IF
    		IF MONTH > 12 THEN error := TRUE; END_IF

    		(* decode year *)
    		YEAR := 0;
    		YEAR.0 := bits[50];
    		YEAR.1 := bits[51];
    		YEAR.2 := bits[52];
    		YEAR.3 := bits[53];
    		IF bits[54] THEN YEAR := YEAR + 10; END_IF
    		IF bits[55] THEN YEAR := YEAR + 20; END_IF
    		IF bits[56] THEN YEAR := YEAR + 40; END_IF
    		IF bits[57] THEN YEAR := YEAR + 80; END_IF

    		(* check parity for bits 36 to 58 *)
    		cnt := 0;
    		FOR i := 36 TO 58 DO IF bits[i] THEN cnt := cnt + 1; END_IF END_FOR
    		IF NOT EVEN(cnt) THEN error := TRUE; END_IF

    		(* time must be valid for two cycles to clear error flag *)
    		IF NOT error THEN
    			(* set outputs *)
    			old_time := mez;
    			IF YEAR >= 70 THEN YEAR := YEAR + 1900; ELSE YEAR := YEAR + 2000; END_IF
    			mez := SET_DT(YEAR,MONTH,day,HOUR,MINUTE,0);
    			DS := bits[17];
    			IF DS THEN
    				UTC := DWORD_TO_DT(DT_TO_DWORD(mez) - 7200);
    			ELSE
    				UTC := DWORD_TO_DT(DT_TO_DWORD(mez) - 3600);
    			END_IF

    			(* set trigger signal only if the receiver has received 2 successive minutes *)
    			IF mez <> old_time + t#1m THEN error := TRUE ; END_IF
    		END_IF
    	END_IF
    END_IF

    (* this portion implements a free running clock which is triggered by the dcf77 signal *)
    tz := DWORD_TO_TIME(INT_TO_DWORD(ABS(time_offset))* 3600000);

    (* input sdt is copied to utc at first power up *)
    IF NOT init OR SET THEN
    	init := TRUE;
    	utc := sdt;
    	tp := TRUE;
    	DS := DSI;
    END_IF

    IF tp THEN
    	rtc := utc;
    	IF DS AND dst_en THEN
    		IF time_offset < 0 THEN	rtc1 := rtc - tz + t#1h; ELSE rtc1 := rtc + tz + t#1h; END_IF
    	ELSE
    		IF time_offset < 0 THEN rtc1 := rtc - tz; ELSE rtc1 := rtc + tz; END_IF
    	END_IF
    	sync := TRUE;
    	last_sync := last;
    	ty := last;
    ELSIF rtc > DWORD_TO_DT(0) AND T1 - ty >= t#1s THEN
    	rtc := rtc + t#1s;
    	rtc1 := rtc1 + t#1s;
    	ty := ty + t#1s;
    	sync := ty - last_sync < sync_timeout AND last_sync > DWORD_TO_TIME(0);
    	wday := DAY_OF_WEEK(DT_TO_DATE(rtc1));
    	DS := dst_en AND DST(utc);
    END_IF
    msec := TIME_TO_INT(t1 - ty);



    (* decode information
    bits		content
    0			Bitwert immer 0
    1 bis 14	reserviert für Betriebsinformationen (nicht für DCF77-Nutzer bestimmt)
    15			Rufbit für Alarmierung der PTB-Mitarbeiter
    			(bis Mai 2003: Bitwert = 0 falls normale Antenne in Verwendung; 1 = Backupantenne)
    16			Bitwert = 1 falls ein Wechsel von MEZ nach MESZ oder umgekehrt bevorsteht; Dauer der Anzeige: 1 Stunde
    17 + 18	gültige Zeit = MEZ, falls Bit 17=0 und Bit 18=1
    			gültige Zeit = MESZ, falls Bit 17=1 und Bit 18=0
    19			Bitwert = 1 falls innerhalb den nächsten 59 Minuten eine Schaltsekunde angeordnet ist. Beim Einfügen einer Schaltsekunde wird anstelle der 59. die 60. Sekundenmarke weggelassen und in der 58. erfolgt ausnahmsweise ein Trägerabfall.
    20			Startbit für Zeitinformation (immer 1)
    21 - 27		1, 2, 4, 8, 10, 20, 40 Minuten (bitweise Addition)
    28			Prüfbit (gerade Parität) für die Bits 21-27
    29 - 34		1, 2, 4, 8, 10, 20 Stunden (bitweise Addition)
    35			Prüfbit (gerade Parität) für die Bits 29-34
    36 - 41		Tagesnummer im aktuellen Monat: 1, 2, 4, 8, 10, 20 (bitweise Addition)
    42 - 44		Tagesnummer in der aktuellen Woche: 1, 2, 4 (bitweise Addition)
    45 - 49		Monatsnummer: 1, 2, 4, 8, 10 (bitweise Addition)
    50 - 57		Jahr (zweistellig): 1, 2, 4, 8, 10, 20, 40, 80 (bitweise Addition)
    58			Prüfbit (gerade Parität) füR die Bits 36-57

    *)
    (* revision history

    hm 2.feb 2007		rev 1.1
    	change wday and dst outputs when there is no dcf reception

    hm	26.feb 2007		rev 1.2
    	changed statements where t#1h would be substracted from DT.
    	under certain conditions the compiler would crash translating this statement

    hm	17. sep 2007	rev 1.3
    	replaced time() with T_PLC_MS() for compatibility reasons

    hm	24. oct 2007		rev 1.4
    	changed dst calculation because function dst was upgraded no error in DCF77 only a change in DST

    hm	12. nov 2007		rev 1.5
    	changed time_offset from time to integer to allow for negative offset time zones

    hm	8. dec 2007		rev 1.6
    	corrected an error in time_zone calculation

    hm 23. jan 2008		rev 1.7
    	added sdt input which is used to initialize rtc and rtc1 during first cycle.

    hm 16. mar 2008		rev 1.8
    	changed output weekday to wday and dst to ds for compatibility reasons

    hm	19. apr. 2008	rev 1.9
    	added input dsi to allow to set daylight savings time when SDT is TRUE.
    	added asynchronous SET input

    hm	7. oct. 2008	rev 1.10
    	changed function weekday to day_of_week

    *)



END_FUNCTION_BLOCK