TYPE
    ESR_DATA :    STRUCT
        TYP : BYTE; (**)
        ADRESS : STRING[10]; (**)
        DS : DT; (**)
        TS : TIME; (**)
        DATA : ARRAY[0..7] OF BYTE; (**)
    END_STRUCT;
END_TYPE