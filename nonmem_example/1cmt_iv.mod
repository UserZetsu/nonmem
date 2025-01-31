$PROBLEM PK model

$INPUT 	;; Change to dataset
  ID TIME DV MDV AMT RATE

$DATA 1cmt_iv.csv IGNORE=#  

$SUBROUTINES 
  ADVAN1 TRANS2 	;; 1-compartment iv data

$PK
  CL = THETA(3) * EXP(ETA(1))
  V = THETA(4) * EXP(ETA(2))
  
  S1 = V   ;; scaling of compartment check units of dose and observations

$THETA  	;; set realistic initial estimates (also for proportional and additive error)
  (0, 0.1) 	;1 prop
  (0, 0.5)  	;2 add
  (0, 30)    	;3 CL
  (0, 200)   	;4 V

$OMEGA 
  0.09      		;; IIV-CL
  0.09  		;; IIV-V

$SIGMA
  1 FIX  ;residual variability

$ERROR  	;; For calculation based on linear (non log-transformed) data
  IPRED = F
  IRES = DV-IPRED
  W = IPRED*THETA(1)+THETA(2)
  IF (W.EQ.0) W = 1
  IWRES = IRES/W
  Y= IPRED+W*ERR(1)

$EST METHOD=1 MAXEVAL=99999 SIG=3 PRINT=5 NOABORT POSTHOC INTERACTION  	;; Estimation method FOCE+interaction

$COV PRINT=E UNCONDITIONAL

$TABLE ID TIME IPRED IWRES CWRES EVID MDV TIME NOPRINT ONEHEADER FILE=SDTAB001
$TABLE ID CL V ETA1 ETA2 NOPRINT ONEHEADER FILE=PATAB001
$TABLE ID NOPRINT ONEHEADER FILE=COTAB001
$TABLE ID NOPRINT ONEHEADER FILE=CATAB001