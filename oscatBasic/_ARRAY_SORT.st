FUNCTION _ARRAY_SORT
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=75*)
    (* Startwerte zur Arraygröße *)
    links := 1;					(* Anfangselement des Arrays *)
    rechts := SHR(SIZE,2);		(* Endelement des Arrays *)
    stack_count := 1;			(* Laufvariable stack *)

    WHILE NOT ende_aussen DO						(* äußere Schleife *)
    	IF links < rechts THEN
    		pivot := PT[SHR(rechts+links,1)];			(* Wert des mittleren Elements als pivot-Wert *)
    		i := links -1;
    		j := rechts +1;

    		(* innere Schleife, teile Feld *)
    		ende_innen := FALSE;
    		REPEAT

    			(* steigende Reihenfolge *)
    			REPEAT	i := i+1;	UNTIL (PT[i] >= pivot) OR NOT (i < rechts)	END_REPEAT
    			REPEAT	j := j-1;	UNTIL (PT[j] <= pivot) OR NOT (j > links)	END_REPEAT


    			(*sinkende Reihenfolge *)
    (*			REPEAT	i := i+1;	UNTIL (PT[i] <= pivot) OR NOT (i < rechts)	END_REPEAT	*)
    (*			REPEAT	j := j-1;	UNTIL (PT[j] >= pivot) OR NOT (j > links)	END_REPEAT	*)

    			IF i >= j THEN
    				ende_innen := TRUE;
    			ELSE
    				   tmp := PT[j];
    				PT[j] := PT[i];
    				PT[i] := tmp;
    			END_IF

    		UNTIL ende_innen END_REPEAT

    		(* Push stack *)
    		stack[stack_count] := rechts;		(* rechten Teil später sortieren *)
    		IF stack_count < 32 THEN
    			stack_count := stack_count +1;
    		ELSE
    			ende_aussen := TRUE;
    			_ARRAY_SORT := FALSE;					(* Fehler: stack zu klein *)
    		END_IF

    		(* linken Teil sortiern *)
    		rechts := MAX(links, i-1);

    	ELSE

    		IF stack_count = 1 THEN
    			ende_aussen := TRUE;
    		ELSE

    			links := rechts+1;

    			(* pop stack *)
    			stack_count := stack_count -1;		(* jetzt rechten Teil sortierne *)
    			rechts:= stack[stack_count];
    		END_IF

    	END_IF

    END_WHILE

    _ARRAY_SORT := TRUE;				(* Sortierung beendet *)


    (* algorithm used before rev 2.0

    SIZE := SHR(SIZE,2);
    size2 := UINT_TO_INT(SHR(SIZE,1));
    FOR i := SIZE2  TO 1 BY -1 DO
    	j:=i;
        WHILE j <= SIZE2 DO
         	stop := j * 2 + 1;
            IF stop > UINT_TO_INT(SIZE) THEN stop := stop - 1;
            ELSIF PT[stop-1] > PT[stop] THEN stop := stop - 1;
    		END_IF
            IF PT[j] < PT[stop] THEN
             	temp := PT[j];
                PT[j] := PT[stop];
                PT[stop] := temp;
            END_IF
            j := stop;
        END_WHILE
    END_FOR

    *)

    (* heapsort
    FOR heapsize := UINT_TO_INT(SIZE) TO 1 BY -1 DO
    	popmax := PT[1];
    	PT[1] := PT[heapsize];
       	i := 1;
    	hs2 := SHR(heapsize,1);
    	WHILE i <= hs2 DO
           	stop := i * 2 + 1;  
            	IF stop > heapsize THEN stop := stop - 1;
            	ELSIF PT[stop-1] > PT[stop] THEN stop := stop - 1;
    	 	END_IF
            	IF PT[i] < PT[stop] THEN
                		temp := PT[i];
                		PT[i] := PT[stop];
                		PT[stop] := temp;
            	END_IF
            	i := stop;
        	END_WHILE
    	PT[heapsize] := popmax;
    END_FOR

    _ARRAY_SORT2 := TRUE;
    *)

    (* old algorithm bubble sort used before rev 1.2
    stop := (SIZE - SIZEOF(PT)) / SIZEOF(PT);
    FOR i := 0 TO stop - 1 DO
    	FOR m := i + 1 TO stop DO
    		IF PT[i] > PT[m] THEN
    			temp := PT[i];
    			PT[i] := PT[m];
    			PT[m] := temp;
    		END_IF
    	END_FOR
    END_FOR
    _ARRAY_SORT := TRUE;

    *)


    (* revision history

    hm 	6.1.2007 	rev 1.1
    	changed return value to true

    hm	22. sep 2007	rev 1.2
    	changed sorting algorithm to heap sort for performance reasons

    hm 	14. nov 2007	rev 1.3
    	changed calculation of stop to be more efficient

    hm	15 dec 2007	rev 1.4
    	added function return true

    hm	5. jan 2008		rev 1.5
    	improved performance

    hm	16. mar. 2008	rev 1.6
    	changed type of input SIZE to uint

    hm	28. mar. 2008	rev 1.7
    	changed input f to PT

    hm	19. jan. 2011	rev 2.0
    	new faster algorithm using qucksort (Alexander Drikitis)

    *)

END_FUNCTION
