FUNCTION WATER_ENTHALPY
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=453*)
    WATER_ENTHALPY := LINEAR_INT(T, data, Pts);



    (*
        °C - die Celsius-Temperatur in Grad Celsius
        v – das spezifische Volumen in Kubikdezimeter je Kilogramm dm³/kg
        h – die spezifische Enthalpie in Kilojoule je Kilogramm 	kJ/kg
        u – die spezifische Innere Energie in Kilojoule je Kilogramm 	kJ/kg
        s – die spezifische Entropie in Kilojoule je Kilogramm mal Kelvin 	kJ/(kg·K)
        cp - die spezifische Wärmekapazität bei konstantem Druck in Kilojoule je Kilogramm mal Kelvin 	kJ/(kg·K)
        Y – Volumenausdehnungskoeffizient in 10-3 durch Kelvin  10-3/K
        L – Wärmeleitfähigkeit in Milliwatt je Meter mal Kelvin  mW / (m·K) 
        n – Viskosität in Mikropascal mal Sekunde uPa·s 	
        s ? – Oberflächenspannung in Millinewton je Meter  mN/m


    °C 		v 				h 			u 		s 			cp 		Y 		L		n		s	
    -20		1,006580	
    0 		1,000160 		0,06 		-0,04 	-0,0001 	4,228 	-0,080 	561,0 	1792 	75,65
    4		1,000028
    5 		1,0000 		21,1 		21,0 	0,076 		4,200 	0,011 	570,6 	1518 	74,95
    10 		1,0003 		42,1 		42,0 	0,151 		4,188 	0,087 	580,0 	1306 	74,22
    15 		1,0009 		63,0 		62,9 	0,224 		4,184 	0,152 	589,4 	1137 	73,49
    20 		1,001797 		83,9 		83,8 	0,296 		4,183 	0,209 	598,4 	1001 	72,74
    25 		1,0029 		104,8 		104,7 	0,367 		4,183 	0,259 	607,2 	890,4 	71,98
    30 		1,0044 		125,8 		125,7 	0,437 		4,183 	0,305 	615,5 	797,7 	71,20
    35 		1,0060 		146,7 		146,6 	0,505 		4,183 	0,347 	623,3 	719,6 	70,41
    40 		1,007842 		167,58 	167,5 	0,572 		4,182 	0,386 	630,6 	653,3 	69,60
    45 		1,0099 		188,5 		188,4 	0,638 		4,182 	0,423 	637,3 	596,3 	68,78
    50 		1,0121 		209,4 		209,3 	0,704 		4,181 	0,457 	643,6 	547,1 	67,95
    60 		1,017089 		251,2 		251,1 	0,831 		4,183 	0,522 	654,4 	466,6 	66,24
    70 		1,0227 		293,1 		293,0 	0,955 		4,187 	0,583 	663,1 	404,1 	64,49
    80 		1,029027 		335,0 		334,9 	1,075 		4,194 	0,640 	670,0 	354,5 	62,68
    90 		1,0359 		377,0 		376,9 	1,193 		4,204 	0,696 	675,3 	314,6 	60,82
    99,63 	1,0431 		417,5 		417,4 	1,303 		4,217 	0,748 	679,0 	283,0 	58,99
    100	1,043453		419,1

    Stoffdaten von Wasser Quelle Wickipedia

    Wasser hat unter Normaldruck seine größte Dichte von 1000 Kilogramm pro Kubikmeter bei 3,98 °C und zeigt damit eine Dichteanomalie. 
    Diese besteht darin, dass sich Wasser unterhalb von 3,98 °C bei weiterer Temperaturverringerung, auch beim Wechsel zum festen 
    Aggregatzustand, wieder ausdehnt, was man nur von wenigen Stoffen kennt. Die derzeit genauesten publizierten Werte für die maximale 
    Dichte liegen bei (999,974950 ± 0,00084) kg/m³ und bei (3,983 ± 0,00067) °C für die Temperatur, bei der dieser Wert erreicht wird. 
    Die Werte stellen einen Mittelwert der von verschiedenen physikalischen Instituten veröffentlichten Zahlen dar (Stand 2001).

    Die Berechnung der Dichte von luftfreiem Wasser DLF in Abhängigkeit von der Temperatur T ([T] = °C) kann mit Hilfe der folgenden 
    Virialgleichung erfolgen:
    : \frac{D_{\rm LF}}{\rm g/l} = \frac{a_0 + a_1 T + a_2 T2 + a_3 T3 + a_4 T4 + a_5 T5}{1 + b T}.
    mit den Koeffizienten: a0 = 999,83952; a1 = 16,952577 (°C)-1; a2 = -7,9905127·10-3 (°C)-2; a3 = -4,6241757·10-5 (°C)-3; 
    a4 = 1,0584601·10-7 (°C)-4; a5 = -2,8103006·10-10 (°C)-5 und b = 0,0168872. 
    Für die Berechnung der Dichte von luftgesättigtem Wasser korrigiert man den Wert nach 
    DLG/(g/l) = DLF/(g/l) - 0,004612 + 0,000106 (°C)-1·T. (Quelle: PTB-Mitteilungen 100/3-90)

    *)

    (* revision history
    hm	13. mar. 2009	rev 1.0
    	original version

    hm	13. mar. 2009	rev 1.1
    	real constants updated to new systax using dot

    *)
END_FUNCTION
