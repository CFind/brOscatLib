FUNCTION DEW_CON
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=434*)
    (*	this code is good to read but need to be improoved
    	SDD := 6.1078*EXPT(10,(a*T)/(b+T));
    	DD := RH/100 * SDD;
    	V := LOG(DD/6.1078);
    	TD := b*V/(a-v);
    	DEW_CON := 0.1 * mw / RU * DD / (T - TK);
    *)
    IF RH > 0.0 AND T > -50.0 THEN
    	DEW_CON := 2.166824303E-2 * RH * SDD(T,FALSE)  / (T - cT0);
    ELSE
    	DEW_CON := 0.0;
    END_IF

    (*
    Bezeichnungen:
    r = relative Luftfeuchte
    T = Temperatur in °C
    TK = Temperatur in Kelvin (TK = T + 273.15)
    TD = Taupunkttemperatur in °C
    DD = Dampfdruck in hPa
    SDD = Sättigungsdampfdruck in hPa

    Parameter:
    a = 7.5, b = 237.3 für T >= 0
    a = 7.6, b = 240.7 für T < 0 über Wasser (Taupunkt)
    a = 9.5, b = 265.5 für T < 0 über Eis (Frostpunkt)

    R* = 8314.3 J/(kmol*K) (universelle Gaskonstante)
    mw = 18.016 kg (Molekulargewicht des Wasserdampfes)
    AF = absolute Feuchte in g Wasserdampf pro m3 Luft

    Formeln:

       1. SDD(T) = 6.1078 * 10((a*T)/(b+T))
       2. DD(r,T) = r/100 * SDD(T)
       3. r(T,TD) = 100 * SDD(TD) / SDD(T)
       4. TD(r,T) = b*v/(a-v) mit v(r,T) = log10(DD(r,T)/6.1078)
       5. AF(r,TK) = 105 * mw/R* * DD(r,T)/TK; AF(TD,TK) = 105 * mw/R* * SDD(TD)/TK 

    *)

    (* revision history

    hm 29 apr 2007	rev 1.0
    	original version

    hm	13.sep 2007	rev 1.1
    	improoved coding for speed
    	deleted unused variabled SDD,DD,V, TD

    hm	2. dec 2007	rev 1.2
    	changed code for better performance
    	output is now in Gramms / Qubic meter

    hm	14. oct. 2008	rev 1.3
    	performance improvement

    hm	18. oct. 2008	rev 1.4
    	using phys constants

    hm	13. mar. 2009	rev 1.5
    	improved code

    hm	19. jan. 2011	rev 1.6
    	return value 0.0 if RH <= 0.0

    *)
END_FUNCTION
