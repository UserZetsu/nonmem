;; 1. Based on: 1cmt_oral
;; 2. Description: PK model 1 cmt oral MM

;; x1. Author: user
$PROBLEM PK model

$INPUT 	;; Change to dataset
  ID TIME DV MDV AMT II ADDL

$DATA 2cmt_oral.csv IGNORE=#  

$SUBROUTINE		ADVAN13 TOL=6

$MODEL      	NCOMP=2
				COMP=(DEPOT,DEFDOSE)      ; Absorption compartment with default dosing
        COMP=(TRANSIT)            ; Transit compartment

$PK
; ------- Typical parameters -------
VMAX = THETA(3) * EXP(ETA(1)) ; nonlinear CL
KM   = THETA(4) * EXP(ETA(2))
V    = THETA(5) * EXP(ETA(3))
KA   = THETA(6)

F1   = 1
S2   = V

$DES
CP      = A(2)/V
DADT(1) = -KA*A(1)
DADT(2) =  KA*A(1) - VMAX*CP/(KM+CP) 


$THETA  	;; set realistic initial estimates (also for proportional and additive error)
  (0, 0.1) 	;1 prop
  (0, 0.5)  	;2 add
  (0, 10)    	;3 VMAX
  (0, 200)   	;4 KM
  (0, 1000)   ;5 V
  (0, 0.32)   ;6 KA

$OMEGA 
  0.09      ;; IIV-VMAX
  0.09  		;; IIV-KM
  0.09  		;; IIV-V

$SIGMA
  1 FIX  ;residual variability

$ERROR  	;; For calculation based on linear (non log-transformed) data
 IPRED = A(2)/V
  IRES = DV-IPRED
  W = IPRED*THETA(1)+THETA(2)
  IF (W.EQ.0) W = 1
  IWRES = IRES/W
  Y= IPRED+W*ERR(1)

$EST METHOD=1 MAXEVAL=99999 SIG=3 PRINT=5 NOABORT POSTHOC INTERACTION ;; Estimation method FOCE+interaction

$COV PRINT=E UNCONDITIONAL

$TABLE ID TIME IPRED IWRES CWRES EVID MDV TIME NOPRINT ONEHEADER FILE=SDTAB003
$TABLE ID ETA1 ETA2 NOPRINT ONEHEADER FILE=PATAB003
$TABLE ID NOPRINT ONEHEADER FILE=COTAB003
$TABLE ID NOPRINT ONEHEADER FILE=CATAB003