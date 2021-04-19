FUNCTION_BLOCK BLIND_SHADE_S
    (* status definition
       151 = shadow               move shutter down for shadowing
       152 = alert                  move shutter up by setting QU:=TRUE when door is open.
    *)

    (* the input sun is sent through tof which will delay the shade for the time shade_delay *)
    sun_delay(IN := sun, PT := shade_delay);

    IF ALERT THEN
       QU := TRUE;
       QD := FALSE;
       STATUS := 152;
    ELSIF UP AND DN AND ENABLE AND sun_delay.Q
    AND (CX.SUN_HOR > HORZ1) AND (CX.SUN_HOR < HORZ2)
    AND (CX.SUN_VER < VERT)
    AND (DT_TO_TOD(CX.UTC) > CX.SUN_RISE + sunrise_offset) AND (DT_TO_TOD(CX.UTC) < CX.SUN_SET - sunset_preset) THEN
       QU := UP;
       QD := DN;
       STATUS := 151;
       (* Calculate Position, must be shade_pos or less *)
       PO := MIN(PI, shade_pos);
    ELSE
       QU := UP;
       QD := DN;
       PO := PI;
       STATUS := S_IN;
    END_IF



    (* revision history
    hf	12 nov. 2009	rev 1.0
    	original version

    *)
END_FUNCTION_BLOCK