FUNCTION_BLOCK SNTP_CLIENT
    (*http://www.oscat.de/images/OSCATNetwork/oscat_netlib121_en.pdf#page=127*)
    (* Domain Name System (query) *)
    tx := T_PLC_MS(); (* read system time *)

    CASE state OF
    00: (* auf positive Flanke SET warten *)
    	DONE_P := FALSE;
    	IF ACTIVATE AND NOT activate_last THEN
    		ip4_stored := IP4; (* aktuelle IP4 speichern *)
    		state := 10;
    		ERROR := DWORD#0;
    		ip_state := BYTE#1; (* Anmelden *)
    		(*####################  DEBUG-MESSAGE  ###################################*)
    		(*IF _debug_enable THEN
    			LOG_CL.NEW_MSG := 'SNTP: S00 START';
    			LOG_MSG();
    		END_IF*)
    		(*########################################################################*)
    	END_IF

    10: (* Bei IP_Control anmelden und auf freigabe warten *)
    	IF ip_state = BYTE#3 THEN

    		S_BUF.BUFFER[00] := BYTE#16#1B;
    		FOR i := 1 TO 47 DO
    			S_BUF.BUFFER[i] := BYTE#16#00;
    		END_FOR

    		last := tx; (* aktuellen time wert sichern *)
    		state := 30;

    		(* IP Datenverkehr einrichten *)
    		IP_C.C_PORT := WORD#123; (* Portnummer eintragen *)
    		IP_C.C_IP := ip4_stored; (* IP eintragen *)
    		IP_C.C_MODE := BYTE#1; (* Mode: UDP+AKTIV+PORT+IP *)
    		IP_C.C_ENABLE := TRUE; (* Verbindungsaufbau freigeben *)
    		IP_C.TIME_RESET := TRUE; (* Zeitueberwachung rücksetzen *)
    		IP_C.R_OBSERVE := TRUE; (* Datenempfang ueberwachen *)
    		S_BUF.SIZE := UINT#48; (* Sendelänge eintragen *)
    		R_BUF.SIZE := UINT#0; (* Empfangslänge rücksetzen *)
        		(*####################  DEBUG-MESSAGE  ###################################*)
        		(*IF _debug_enable THEN
          			LOG_CL.NEW_MSG := 'SNTP: S10 SEND';
          			LOG_MSG();
        		END_IF*)
        		(*########################################################################*)
    	END_IF

    30:
    	IF IP_C.ERROR <> DWORD#00 THEN
    		ERROR := IP_C.ERROR;
    		S_BUF.SIZE := UINT#0;
    		R_BUF.SIZE := UINT#0;
    		state := 0;
        		(*####################  DEBUG-MESSAGE  ###################################*)
        		(*IF _debug_enable THEN
          			LOG_CL.NEW_MSG := 'SNTP: S30 ERROR ~1';
          			LOG_CL.PRINTF[1] := DWORD_TO_STRING(ERROR);
          			LOG_MSG();
        		END_IF*)
        		(*########################################################################*)

    	ELSIF S_BUF.SIZE = UINT#0 AND R_BUF.SIZE >= UINT#48 THEN (* länge der empfangenen Daten prüfen *)

    		(* Umrechnung SNTP Timestamp Base 1900-01-01 -> Unix 1970-01-01 = +2208988800 sekunden*)
    		UDT := DWORD_TO_DT(DWORD_OF_BYTE(R_BUF.BUFFER[40],R_BUF.BUFFER[41],R_BUF.BUFFER[42],R_BUF.BUFFER[43]) - DWORD#2208988800);

    		(* Original-Sekundenanteile sind als 32 Bit Fractal dargestellt *)
    		(* ms nur mit veringerte Auflösung berechnen 1/65535 -> Highword verwenden *)
    		XMS := DWORD_TO_INT(SHR(DINT_TO_DWORD(WORD_TO_DINT(WORD_OF_BYTE(R_BUF.BUFFER[44],R_BUF.BUFFER[45])) * DINT#1000),16));
    		(* Zeitdifferenz (Laufzeitfehler) zwischen Send und Receive /2 teilen und addieren *)
    		XMS := XMS + DWORD_TO_INT(SHR(tx - last,1));

    		UDT := DWORD_TO_DT(DT_TO_DWORD(UDT) + (XMS / 1000)); (* sekundenanteile der Zeitdifferenz zu UDT aufrechnen *)
    		XMS := XMS MOD 1000;  (* ms übernehmen *)
    		state := 0;
    		DONE_P := TRUE;
        		(*####################  DEBUG-MESSAGE  ###################################*)
        		(*IF _debug_enable THEN
            			LOG_CL.NEW_MSG := 'SNTP: S30 OK';
            			LOG_MSG();
        		END_IF*)
        		(*########################################################################*)

    	END_IF

    	IF state = 0 THEN
    		IP_C.R_OBSERVE := FALSE; (* Datenempfang ueberwachen *)
    		ip_state := BYTE#4;
    	END_IF

    END_CASE

    activate_last := ACTIVATE; (* letzten Status sichern zur Flankenerkennung *)

    (* IP_FIFO *)
    IP_FIFO(FIFO:=IP_C.FIFO,state:=ip_state,ID:=ip_id);

    (* revision history
    ks	18. oct. 2008	rev 1.0
    	original version

    ks	20. oct. 2009	rev 1.1
    	Networkbuffer und Buffer-funktionen auf Basis 0

    *)

    (***************************************************************************************)
    (*               SNTP Datenstruktur
                                      1                   2                   3   
                  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 01-04  |LI | VN  |Mode |    Stratum    |     Poll      |   Precision   |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 05-08  |                          Root  Delay (32 Bit)                 |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 09-12  |                       Root  Dispersion (32 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 13-16  |                     Reference Identifier (32 Bit)             |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 17-24  |                    Reference Timestamp (64 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 25-32  |                    Originate Timestamp (64 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 33-40  |                     Receive Timestamp (64 Bit)                |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 41-48  |                     Transmit Timestamp (64 Bit)               |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 49-52  |                 Key Identifier (optional) (32 Bit)            |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    Byte: 53-68  |                 Message Digest (optional) (128 Bit)           |
                 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

    *)

    (*
    Worldwide NTP-Server


    NIST-Zeitserver
    • time-a.nist.gov
    129.6.15.28 
    NIST, Gaithersburg, Maryland 
    • time-a.nist.gov
    129.6.15.28 
    NIST, Gaithersburg, Maryland 
    • time-a.timefreq.bldrdoc.gov
    132.163.4.101 (Stand: 1. Dezember 1999)
    NIST, Boulder, Colorado 
    • time-b.timefreq.bldrdoc.gov
    132.163.4.102 (Stand: 1. Dezember 1999)
    NIST, Boulder, Colorado 
    • time-c.timefreq.bldrdoc.gov
    132.163.4.103 (Stand: 1. Dezember 1999)
    NIST, Boulder, Colorado 
    • utcnist.colorado.edu
    128.138.140.44
    University of Colorado, Boulder 
    • time.nist.gov
    192.43.244.18
    NCAR, Boulder, Colorado 
    • time-nw.nist.gov
    131.107.1.10
    Microsoft, Redmond, Washington 
    • nist1.dc.certifiedtime.com
    216.200.93.8
    Abovnet, North Virginia 
    • nist1.datum.com
    209.0.72.7
    Datum, San Jose, Kalifornien 
    • nist1.nyc.certifiedtime.com
    208.184.49.129 
    Abovnet, New York City 
    • nist1.sjc.certifiedtime.com
    207.126.103.202
    Abovnet, San Jose, Kalifornien 

    Zeitserver der ersten Ebene
    Sortiert nach Standort: 
    Nordamerika
    • Palo Alto, Kalifornien: Systems Research Center, Compaq Computer Corp.
    204.123.2.72: usno.pa-x.dec.com; CNAME: navobs1.pa-x.dec.com
    Servicebereich: US-Zeitzonen PST (Pacific Standard Time) und MST (Mountain Standard Time) 
    • Marina del Rey, Kalifornien: USC Information Sciences Institute
    128.9.176.30: timekeeper.isi.edu
    Servicebereich: CalRen2- und Los Nettos-Bereich  
    • Washington, DC: U.S. Naval Observatory
    192.5.41.41: tock.usno.navy.mil 
    192.5.41.40: tick.usno.navy.mil
    Servicebereich: NSFNET 
    • Ottawa, Ontario, Kanada: National Research Council of Canada
    time.chu.nrc.ca
    Servicebereich: Kanada 
    • Raleigh, North Carolina: North Carolina state University
    152.1.58.124: terrapin.csc.ncsu.edu
    Servicebereich: Südosten der USA 
    • Cambridge, Massachusetts: MIT Information Systems
    18.72.0.3: bitsy.mit.edu 
    Servicebereich: NSFNET- und NEARnet-Bereich 
    • Cambridge, Massachusetts: MIT
    18.26.4.105: bonehed.lcs.mit.edu
    Servicebereich: Osten der USA 
    • Palo Alto, Kalifornien: Internet Software Consortium
    192.5.5.250: clock.isc.org
    Servicebereich: BARRnet, Alternet-West und CIX-West 
    • Cambridge, Massachusetts: Open Software Foundation
    130.105.4.59: clock.osf.org
    Servicebereich: NSFNET- und NEARnet-Bereich 
    • Palo Alto, Kalifornien: ViaNet Communications
    209.81.9.7: clock.via.net 
    • Cleveland, Ohio: Lewis Research Center (NASA)
    128.156.1.43: lerc-dns.lerc.nasa.gov
    Servicebereich: NSFNET und OARNET 
    • Colorado Springs, Colorado: Schriever AFB
    204.34.198.40: navobs1.usnogps.navy.mil; CNAME: tick.usnogps.navy.mil 
    204.34.198.41: navobs1.usnogps.navy.mil; CNAME: tock.usnogps.navy.mil 
    Servicebereich: US-Zeitzonen PST (Pacific Standard Time) und MST (Mountain Standard Time) 
    • St. Louis, Missouri: Washington University
    128.252.19.1: navobs1.usnogps.navy.mil; CNAME: tick.wustl.edu 
    Servicebereich: US-Zeitzone CST (Central Standard Time) 
    • Research Triangle Park, North Carolina: MCNC
    192.101.21.1: ncnoc.ncren.net
    Servicebereich: NC-REN-Bereich (North Carolina Research and Education Network) 
    • Cupertino, Kalifornien: HP
    192.6.38.127: ntp-cup.external.hp.com
    Servicebereich: USA Westküste 
    • Newark, Delaware: Conectiv Communications
    138.39.7.20: ntp1.delmarva.com
    Servicebereich: Cable & Wireless Network (früher MCInet) 
    • University Park, Pennsylvania: Penn state University
    128.118.46.3: otc1.psu.edu
    Servicebereich: NSFNET, PREPNET und JvNCnet  

    Europa
    • Borowiec, Polen: Astrogeodynamical Observatory, Space Research Centre
    150.254.183.15: vega.cbk.poznan.pl
    Servicebereich: Polen und Europa 
    • Stockholm, Schweden: Stupi AB
    192.36.143.151: Time2.Stupi.SE
    Servicebereich: Europa 
    • Turin, Italien: IEN Galileo Ferraris
    193.204.114.1: time.ien.it
    Servicebereich: Italien und Europa 
    • Zürich, Schweiz: Integrated Systems Laboratory , Eidgenössischen Technischen Hochschule Zürich 
    129.132.2.21: swisstime.ethz.ch
    Servicebereich: Schweiz und Europa 
    • Turin, Italien: CSTV of National Research Council
    150.145.33.1: tempo.cstv.to.cnr.it
    Servicebereich: Italien und Europa 
    • Erlangen, Deutschland: Universität Erlangen-Nürnberg
    ntp0.fau.de; ntp1.fau.de; ntp2.fau.de; 
    ntps1-0.uni-erlangen.de; ntps1-1.uni-erlangen.de; ntps1-2.uni-erlangen.de
    Servicebereich: Deutschland und Europa 
    • Berlin, Deutschland: Technische Universität Berlin
    130.149.17.21: ntps1-0.cs.tu-berlin.de
    130.149.17.8: ntps1-1.cs.tu-berlin.de
    Servicebereich: Deutschland und Europa 
    • Deutschland
    131.173.17.7: ntps1-1.rz.Uni-Osnabrueck.DE
    Servicebereich: Deutschland und Europa 
    • Schweden
    192.36.143.150: Time1.Stupi.SE
    Servicebereich: SUnet und NORDUnet Schweden 

    Fernost und pazifische Randgebiete
    • Hong Kong: Chinesische Universität von Hong Kong. 
    137.189.6.18: clock.cuhk.edu.hk
    Servicebereich: Hong Kong (China) und Südostasien  
    • Fukuoka, Japan: Universität Fukuoka
    133.100.9.2: clock.nc.fukuoka-u.ac.jp
    133.100.11.8: clock.tl.fukuoka-u.ac.jp
    Servicebereich: Japan und pazifischer Raum  

    Australien
    • Melbourne, Australien: University of Melbourne
    128.250.36.2: ntp.cs.mu.OZ.AU
    Servicebereich: Australien und Neuseeland  

    Zeitserver der zweiten Ebene
    Nach geographischem Standort sortiert: 
    Nordamerika
    NTP-Zeitserver: • Quebec, Kanada: Canadian Meteorological Center
    ntp1.cmc.ec.gc.ca; ntp2.cmc.ec.gc.ca 
    Servicebereich: Ostkanada  
    • Ontario, Kanada: National Research Council of Canada
    time.chu.nrc.ca; time.nrc.ca
    Servicebereich: Kanada 
    • Saskatchewan, Kanada: University of Regina 
    142.3.100.15: timelord.uregina.ca
    Servicebereich: Kanada 
    • Ontario, Kanada: University of Toronto
    tick.utoronto.ca; tock.utoronto.ca
    Servicebereich: Ostkanada  
    • Mexiko: Audiotel-Büro 
    ntp2a.audiotel.com.mx; ntp2c.audiotel.com.mx; ntp2b.audiotel.com.mx
    Servicebereich: Avantel, MCINet und Mexiko 
    • Santa Cruz, Kalifornien: Scruz-net, inc.
    165.227.1.1: ns.scruz.net
    Servicebereich: Westen der USA 
    • San Diego, Kalifornien: UCSD Academic Computing Services/Network Operations
    132.239.254.49: ntp.ucsd.edu
    Servicebereich: CERFNET; NSFNET, SDSC-Bereich, und nahegelegene Bereiche 
    • Quincy, Kalifornien 
    ntp1.mainecoon.com; ntp2.mainecoon.com 
    Servicebereich: Nordamerika 
    • Newark, Delaware: University of Delaware
    128.175.1.3: louie.udel.edu
    Servicebereich: CAIRN, Abilene und vBNS  
    • Atlanta, Georgia: CNSG
    ntp.shorty.com
    Servicebereich: Südwesten der USA  
    • Kennesaw, Georgia: PeachNet 
    rolex.peachnet.edu; timex.peachnet.edu
    Servicebereich: PeachNet (Georgia) und Südwesten der USA  
    • Urbana-Champaign, Illinois: University of Illinois
    ntp-0.cso.uiuc.edu; ntp-1.cso.uiuc.edu; ntp-2.cso.uiuc.edu
    Servicebereich: CICNET, Mittlerer Westen und NCSA-Bereich  
    • Chicago, Illinois: Argonne National Laboratory 
    ntp-1.mcs.anl.gov; ntp-2.mcs.anl.gov
    Servicebereich: NSF/ANSNet, CICNet, NetIllinois und ESNet  
    • West Lafayette, Indiana: Purdue University
    gilbreth.ecn.purdue.edu; harbor.ecn.purdue.edu; molecule.ecn.purdue.edu 
    Servicebereich: NSFNET- und CICNET-Bereich  
    • Manhattan, Kansas: KansasNet OnLine Services
    199.240.130.1: ntp1.kansas.net
    199.240.130.12: ntp2.kansas.net
    Servicebereich: Zentral-USA und Great Plains  
    • Boston, Massachusetts: UMass-Boston CS dept.
    158.121.104.4: timeserver.cs.umb.edu
    Servicebereich: Neuengland  
    • Minneapolis/St Paul, Minnesota: University of Minnesota
    ns.nts.umn.edu; nss.nts.umn.edu
    Servicebereich: CICNET-Bereich  
    • Columbia, Missouri: University of Missouri-Columbia
    128.206.206.12: everest.cclabs.missouri.edu
    Servicebereich: MOREnet  
    • Omaha, Nebraska: Radiks Internet Access
    205.138.126.83: allison.radiks.net
    Servicebereich: Mittlerer Westen, USA  
    • Las Vegas, Nevada: University of Nevada System Computing Services
    131.216.1.101: cuckoo.nevada.edu 
    Servicebereich: NevadaNet, NSFNET und SDSC-Bereich  
    • Las Vegas, Nevada: UNLV College of Engineering
    tick.cs.unlv.edu; tock.cs.unlv.edu
    Servicebereich: Sprintnet  
    • New York City, New York: Columbia University
    ntp.ctr.columbia.edu 
    Servicebereich: Sprintlink und NYSERnet  
    • Ithaca, New York: Cornell University 
    192.35.82.50: ntp0.cornell.edu
    Servicebereich: NSFNET und NYSER-Bereich  
    • New York, New York: Morningside Campus, Columbia University
    sundial.columbia.edu
    Servicebereich: NYSERnet  
    • New York City, New York: Columbia University Computer Science Department
    timex.cs.columbia.edu 
    Servicebereich: PSINET; NSFNET, und NYSER-Bereich  
    • Norman, Oklahoma: University of Oklahoma
    129.15.22.8: constellation.ecn.uoknor.edu 
    Servicebereich: Midnet  
    • Coos Bay, Oregon: Koala Computers
    207.48.109.6: tick.koalas.com
    Servicebereich: Nordwesten der USA  
    • University Park, Pennsylvania: Penn state University
    128.118.25.3: clock.psu.edu
    Servicebereich: Internet2, vBNS, CERFnet(AT&T IP Services), PSC/NCNE und CASC 
    • Pittsburgh, Pennsylvania: Pittsburgh Supercomputing Center
    128.182.58.100: fuzz.psc.edu
    Servicebereich: NSFNET und PSC-Bereich  
    • Pittsburgh, Pennsylvania: Carnegie Mellon Electrical and Computer Engineering 
    ntp-1.ece.cmu.edu; ntp-2.ece.cmu.edu 
    Servicebereich: PREPNET und PSC-Bereich  
    • Dallas, Texas: Cox School of Business, Southern Methodist University
    129.119.80.126: ntp.cox.smu.edu 
    Servicebereich: NSFNET und SESQUI-Bereich  
    • Hughes Springs, Texas: First National Bank
    209.144.20.76: ntp.fnbhs.com
    Servicebereich: Nordosten Texas  
    • Houston, Texas: Baylor College of Medicine
    128.249.1.10: ntp.tmc.edu 
    Servicebereich: NSFNET und SESQUI-Bereich  
    • College Station, Texas: Texas A&M University
    165.91.52.110: ntp5.tamu.edu
    Servicebereich: NSFNET, SESQUI-Bereich, THEnet und TAMUSDSN 
    • Plano, Texas: Greyware Automation Products
    tick.greyware.com; tock.greyware.com
    Servicebereich: Südzentral-USA  
    • Blacksburg, Virginia: Virginia Tech Computing Center
    ntp-1.vt.edu; ntp-2.vt.edu
    Servicebereich: Südwesten der USA  
    • Arlington, Virginia: Center for Seismic Studies
    140.162.1.3: ntp.cmr.gov
    Servicebereich: NSFNET und SURA-Bereich  
    • Richland, Washington: Washington state University 
    192.31.216.30: clock.tricity.wsu.edu
    Servicebereich: NSFNET und NorthWestNet  
    • Washington, USA: Mill Creek
    time.ultimeth.net
    Servicebereich: Nordwesten der USA  
    • Wisconsin, USA: Computer Science Department, University of Wisconsin-Madison
    ntp1.cs.wisc.edu; ntp2.cs.wisc.edu; ntp3.cs.wisc.edu
    Servicebereich: USA und jeder andere  

    Südamerika
    • Buenos Aires, Argentinien: Network Access Point
    200.49.40.1: CNAME: tick.nap.com.ar
    200.49.32.1: CNAME: tock.nap.com.ar
    Servicebereich: Argentinien 
    • Buenos Aires, Argentinien: Sinectis S.A.
    time.sinectis.com.ar 
    Servicebereich: Argentinien 
    • Brasilien: Brazilian Research Network
    200.144.121.33: ntp.cais.rnp.br 
    Servicebereich: Brasilien 
    • Venezuela: VELUG, Grupo de Usuarios Linux de Venezuela
    150.185.192.250: ntp.linux.org.ve
    Servicebereich: Arica  

    Europa
    • Zürich, Schweiz: Eidgenössischen Technischen Hochschule Zürich
    129.132.98.11: bernina.ethz.ch
    Servicebereich: Schweiz und Europa  
    • Standort: Kopenhagen, Dänemark, Europa 
    clock.netcetera.dk; clock2.netcetera.dk 
    Servicebereich: Dänemark, Skandinavien und Nordeuropa  
    • Spanien: Altea 
    slug.ctv.es
    Servicebereich: Spanien  
    • Pieksamaki, Finnland: Keski-Savon Oppimiskeskus
    tick.keso.fi; tock.keso.fi
    Servicebereich: Finnland  
    • Meudon, Frankreich: Observatoire de Paris-Meudon 
    ntp.obspm.fr 
    Servicebereich: Frankreich und Europa  
    • Lyon, Frankreich: CISM 
    ntp.univ-lyon1.fr 
    Servicebereich: Frankreich, Schweiz, Italien und Europa  
    • Paris, Frankreich: VIA, Ecole Centrale
    138.195.130.70: ntp.via.ecp.fr
    Servicebereich: Frankreich und Europa  
    • Budapest, Ungarn: KFKI Research Institute for Particle and Nuclear Physics
    148.6.0.1: time.kfki.hu
    Servicebereich: HUNGARNET  
    • Italien: Net4u Srl, Vercelli, Italien
    195.32.52.129: ntps.net4u.it
    Servicebereich: Italien  
    • Oslo, Norwegen: Universität Oslo
    129.240.64.3: fartein.ifi.uio.no 
    Servicebereich: NORDUnet  
    • Oslo, Norwegen: Alcanet International
    time.alcanet.no
    Servicebereich: Europa 
    • Krakau, Polen: Academic Computer Centre 
    149.156.4.11: info.cyf-kr.edu.pl
    Servicebereich: Polen und Europa  
    • Lund, Schweden: Lund Institute of Technology
    130.235.20.3: ntp.lth.se 
    Servicebereich: Schweden und NORDUnet 
    • Ljubljana, Slowenien: Institute of Biophysics, University of Ljubljana
    biofiz.mf.uni-lj.si 193.2.69.11
    Servicebereich: Slowenien und Europa  
    • Ljubljana, Slowenien: Hydrometeorological Institute of Slovenia
    hmljhp.rzs-hm.si
    Servicebereich: Slowenien und Europa  
    • Ljubljana, Slowenien: Academic and Research Network of Slovenia
    ntp1.arnes.si; ntp2.arnes.si
    Servicebereich: Slowenien und Europa  
    • Ljubljana, Slowenien: J. Stefan Institute
    time.ijs.si
    Servicebereich: Slowenien und Europa  

    Britische Inseln
    • Dublin, Irland: School of Mathematics, Trinity College 
    ntp.cs.tcd.ie; ntp.maths.tcd.ie; ntp.tcd.ie
    Servicebereich: Irland und Großbritannien 
    • Glasgow, Schottland: Strathclyde University 
    ntp.cs.strath.ac.uk 
    Servicebereich: Großbritannien, Europa und andere 
    • Cambridge, Großbritannien
    ntp0.uk.uu.net; ntp1.uk.uu.net; 
    ntp2.uk.uu.net 
    Servicebereich: UUNET (in Großbritannien früher auch als PIPEX bekannt) und Großbritannien.  
    • Manchester, England: University of Manchester
    ntp2a.mcc.ac.uk; ntp2b.mcc.ac.uk;
    ntp2c.mcc.ac.uk; ntp2d.mcc.ac.uk 
    Servicebereich: Großbritannien  
    • Buckinghamshire, Großbritannien: Wibble U.K., Aylesbury
    tick.tanac.net
    Servicebereich: Großbritannien  

    Asien
    • Moskau, Russland: Landau Institute for Theoretical Physics
    193.233.9.7: ntp.landau.ac.ru
    Servicebereich: Russland  
    • Russland: Pushchino (bei Moskau)
    194.149.67.130: ntp.psn.ru
    Servicebereich: Russland 
    • Chernogolovka, Russland: Chernogolovka Scientific Center (bei Moskau)
    193.233.46.10: sign.chg.ru
    Servicebereich: Russland  

    Fernost und pazifische Randgebiete
    • Tokyo, Japan: Cyber Fleet, Inc.
    203.139.30.195: ntp.cyber-fleet.net
    Servicebereich: Japan und Ostasien  
    • Seoul, Korea: Inet, Inc.
    time.nuri.net
    Servicebereich: Korea, Japan, Hong Kong und Ostasien  
    • Hamilton, Neuseeland: Universität Waikato
    truechimer.waikato.ac.nz; truechimer1.waikato.ac.nz; 
    truechimer2.waikato.ac.nz; truechimer3.waikato.ac.nz
    Servicebereich: Neuseeland  
    • Singapur und Philippinen: 
    ntp.shim.org 
    Servicebereich: Singapur  

    Afrika
    • Lagos, Nigeria: Supernet300
    ntp.supernet300.com
    Servicebereich: Westafrika (hauptsächlich nigerischer NITEL-Backbone)  
    • Pietermaritzburg, Südafrika: Natal University
    143.128.82.200: ntp.cs.unp.ac.za
    Servicebereich: Südafrika  

    Australien
    • Adelaide, Südaustralien: University of Adelaide
    129.127.28.4: augean.eleceng.adelaide.edu.au
    129.127.40.3: ntp.adelaide.edu.au
    203.21.37.18: ntp.saard.net
    Servicebereich: AARNet  
    • Carlton, Victoria, Australien: eSec Limited
    203.21.84.4: time.esec.com.au  

    *)
END_FUNCTION_BLOCK
