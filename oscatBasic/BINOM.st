FUNCTION BINOM
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=42*)
    IF 2 * K > n THEN
    	k := n - k;
    END_IF
    IF k > n THEN
    	RETURN;
    ELSIF k = 0 OR k = n THEN
    	BINOM := 1;
    ELSIF k = 1 THEN
    	BINOM := n;
    ELSE
    	BINOM := n;
    	n := n + 1;
    	FOR i := 2 TO k DO
    		BINOM := BINOM * (n - i) / i;
    	END_FOR
    END_IF



    (*
    binomialkoeffizient(n, k)
    1  wenn k = 0 return 1
    2  wenn 2k > n
    3      dann führe aus ergebnis \leftarrow binomialkoeffizient(n, n-k)
    4  sonst führe aus ergebnis \leftarrow n
    5          von i \leftarrow 2 bis k
    6              führe aus ergebnis \leftarrow ergebnis \cdot (n + 1 - i)
    7                        ergebnis \leftarrow ergebnis : i
    8  return ergebnis
    *)



    (* revision history
    hm	25. oct. 2008	rev 1.0
    	original version


    *)
END_FUNCTION