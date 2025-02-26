FUNCTION EXPN
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=49*)
    sign := N.15;
    N := ABS(N);
    IF N.0 THEN EXPN := X; ELSE EXPN := 1.0; END_IF
    N := SHR(N,1);
    WHILE N > 0 DO
       X := X * X;
       IF N.0 THEN EXPN := EXPN * X; END_IF
       N := SHR(N,1);
    END_WHILE
    IF sign THEN EXPN := 1.0 / EXPN; END_IF



    (* revision history
    hm	4. dec 2007	rev 1.0
    	original version

    hm	22. oct. 2008	rev 1.1
    	optimized code

    hm	10. mar. 2009	rev 1.2
    	removed nested comments
    	real constants updated to new systax using dot

    *)
END_FUNCTION
