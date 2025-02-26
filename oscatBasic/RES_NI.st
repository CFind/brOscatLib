FUNCTION RES_NI
    (*http://www.oscat.de/images/OSCATBasic/oscat_basic333_en.pdf#page=318*)
    T2 := T * T;
    RES_NI := R0 + A * T + B * T2 + C * T2 * T2;

    (* revision history

    hm	4.8.2006		rev 1.0
    	original version

    hm	13.9.2007		rev 1.1
    	changed coding for better performance

    hm	2. dec. 2007	rev 1.2
    	changed code for better performance
    *)

    (*

     Auszug aus DIN 43760 für Ni100

    °C		R		°C		R		°C	R		°C		R		°C		R

    -60 	69,5 	-10 	94,6 	40 	123,0 	90 		154,9 	140 	190,9
    -55 	71,9 	-5 		97,3 	45 	126,0 	95 		158,3 	145 	194,8
    -50 	74,3 	0 		100,0 	50 	129,1 	100 	161,8 	150 	198,7
    -45 	76,7 	5 		102,8 	55 	132,2 	105 	165,3 	155 	202,6
    -40 	79,1 	10 		105,6 	60 	135,3 	110 	168,8 	160 	206,6
    -35 	81,6 	15 		108,4 	65 	138,5 	115 	172,4 	165 	210,7
    -30 	84,2 	20 		111,2 	70 	141,7 	120 	176,0 	170 	214,8
    -25 	86,7 	25 		114,1 	75 	145,0 	125 	179,6 	175 	219,0
    -20 	89,3 	30 		117,1 	80 	148,3 	130 	183,3 	180 	223,2
    -15 	91,9 	35 		120,0 	85 	151,6 	135 	187,1 	  	 

    *)
END_FUNCTION
