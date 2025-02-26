FUNCTION FILE_PATH_SPLIT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=153*)
    X.DRIVE := '';
    X.DIRECTORY := '';
    X.FILENAME := '';
    c := LEN(FILENAME);
    IF c = 0 THEN
    	FILE_PATH_SPLIT := FALSE;
    	RETURN;
    END_IF

    FOR b := 1 TO c DO
    	d := MID(FILENAME, 1, b);
    	IF d = ':' THEN
    		p1 := b;
    	ELSIF d = '/' OR d = '\' THEN
    		p2 := b;
    	END_IF
    END_FOR

    IF p1 = 2 THEN
    	X.DRIVE := LEFT(FILENAME,p1);
    END_IF

    IF p2 > 0 AND p2 > p1 THEN
    	X.DIRECTORY := MID(FILENAME,p2 - p1,p1+1); (* len , pos *)
    END_IF

    X.FILENAME := RIGHT(FILENAME,c - MAX (p1,p2));
    FILE_PATH_SPLIT := TRUE;

    (* revision history
    ks	01. jan. 2011	rev 1.0
    	original version
    *)
END_FUNCTION
