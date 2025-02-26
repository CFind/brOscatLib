FUNCTION_BLOCK LOG_MSG
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=111*)
    IF DWORD_TO_BYTE(SHL(LOG_CL.NEW_MSG_OPTION,16)) > LOG_CL.LEVEL THEN RETURN; END_IF (* Logging freigegeben ?*)

    FB_PRINT_SF(PRINTF_DATA := LOG_CL.PRINTF,STR := LOG_CL.NEW_MSG);

    IF LOG_CL.RESET THEN (* Logeinträge löschen *)
    	LOG_CL.RESET := FALSE;
    	LOG_CL.RING_MODE := FALSE;
    	LOG_CL.idX := 0;
    	LOG_CL.UPDATE_COUNT := LOG_CL.UPDATE_COUNT + UINT#1; (* UpdateCount erhöhen *)
    END_IF

    IF LOG_CL.SIZE > 0 THEN (* size wert ist eingetragen *)
    	IF LEN(LOG_CL.NEW_MSG) > 0 THEN (* Meldung in Puffer eintragen *)
    		IF (LOG_CL.idX >= LOG_CL.SIZE) THEN
    			LOG_CL.RING_MODE := TRUE; (* bei Überlauf = Ringbuffermodus *)
    			LOG_CL.idX := 0; (* wieder auf arrayanfang positionieren *)
    		END_IF

    		LOG_CL.UPDATE_COUNT := LOG_CL.UPDATE_COUNT + UINT#1; (* UpdateCount erhöhen *)
    		LOG_CL.idX := LOG_CL.idX + INT#1; (* nächste freie Position *)
    		idX := LOG_CL.idX; (* lade aktuelle Log-Puffer Positition *)
    		LOG_CL.MSG[idX] := LOG_CL.NEW_MSG; (* neuen Log-String in puffer ablegen  *)
    		LOG_CL.MSG_OPTION[idX] := LOG_CL.NEW_MSG_OPTION; (* neue Log-String Option in puffer ablegen  *)
    		LOG_CL.NEW_MSG := ''; (* letzten Log-String löschen *)
    	END_IF
    END_IF
END_FUNCTION_BLOCK
