;; 1. Based on:
;; 2. Description: PK model 2 cmt oral
;; x1. Author: user

$PROBLEM PK model

$INPUT 	;; Change to dataset
  ID TIME DV MDV AMT II ADDL

$DATA 2cmt_oral.csv IGNORE=#  

$SUBROUTINES 
  ADVAN4 TRANS4 	;; 2-compartment oral data

$PK
  CL = THETA(3) * EXP(ETA(1))
  V2 = THETA(4) * EXP(ETA(2))
  V3 = THETA(5) 
  Q = THETA(6) 
  KA = THETA(7)
  
  F1   = 1
  S1 = V2   ;; scaling of compartment check units of dose and observations

$THETA  	;; set realistic initial estimates (also for proportional and additive error)
  (0, 0.1) 	;1 prop
  (0, 0.5)  	;2 add
  (0, 30)    	;3 CL
  (0, 200)   	;4 V2
  (0, 1000)   ;5 V3
  (0, 20)   	;6 Q
  (0, 0.32)   ;7 KA

$OMEGA 
  0.09      ;; IIV-CL
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

$EST METHOD=1 MAXEVAL=99999 SIG=3 PRINT=5 NOABORT POSTHOC INTERACTION ;; Estimation method FOCE+interaction

$COV PRINT=E UNCONDITIONAL

$TABLE ID TIME IPRED IWRES CWRES EVID MDV TIME NOPRINT ONEHEADER FILE=SDTAB002
$TABLE ID CL V2 V3 ETA1 ETA2 NOPRINT ONEHEADER FILE=PATAB002
$TABLE ID NOPRINT ONEHEADER FILE=COTAB002
$TABLE ID NOPRINT ONEHEADER FILE=CATAB002
