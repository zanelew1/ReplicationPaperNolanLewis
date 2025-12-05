****************
*** ECON 582 Replication Study
*** Joey Nolan and Connor Lewis
*** 5DEC25
****************

clear all

global route "/Users/connorlewis_macbookpro/Desktop/ReplicationPaperNolanLewis"
set matsize 800
set memory 200m
set more 1
quietly capture log close

*do tables1211_1_setup.do

*******************************
*
* Make addstat command for outreg
*******************************
	capture program drop XXaddstat
	program XXaddstat
		*make flags for each instrument
		local rail 		= cond(strmatch(e(exexog),"*l_rail1898*")==1 & strmatch(e(exexog),"*l_rail1898_b20*")==0	,1,.)
		local hwy  		= cond(strmatch(e(exexog),"*l_hwy1947*")==1 & strmatch(e(exexog),"*l_hwy1947_b20*")==0		,1,.)
		local expl 		= cond(strmatch(e(exexog),"*l_pix_pre1850*")==1 & strmatch(e(exexog),"*l_pix_pre1850_b20*")==0	,1,.)
		local rail_b20 		= cond(strmatch(e(exexog),"*l_rail1898_b20*")==1						,1,.)
		local hwy_b20  		= cond(strmatch(e(exexog),"*l_hwy1947_b20*")==1							,1,.)
		local expl_b20 		= cond(strmatch(e(exexog),"*l_pix_pre1850_b20*")==1						,1,.)
		*make flags for sets of controls
		local geog 		= cond(strmatch( e(inexog),"*$geography*")==1,1,.)
		local geog_ext 		= cond(strmatch( e(inexog),"*$geography_ext*")==1,1,.)
		local pop20_70 		= cond(strmatch( e(inexog),"*$population*")==1,1,.)
		local pop80 		= cond(strmatch( e(inexog),"*l_pop80*")==1,1,.)
		local pop90 		= cond(strmatch( e(inexog),"*l_pop90*")==1,1,.)
		local emp83 		= cond(strmatch( e(inexog),"*l_emp83*")==1,1,.)
		local emp93 		= cond(strmatch( e(inexog),"*l_emp93*")==1,1,.)
		local cd		= cond(strmatch( e(inexog),"*$cen_div")==1,1,.)
		local socio		= cond(strmatch( e(inexog),"*mean_income*")==1,1,.)

		*only display overid test if model is overidentified
		if e(jdf)==0{
			global Xaddstat "addstat(Rail_b20,`rail_b20', 
							Hwy_b20,`hwy_b20', 
							Expl_b20,`expl_b20', 
							Rail,`rail', 
							Hwy,`hwy', 
							Expl,`expl', 
							pop80,`pop80', 
							pop90,`pop90', 
							emp83,`emp83', 
							emp93,`emp93', 
							hist pop, `pop20_70', 
							Geog,`geog', 
							Geog Ext,`geog_ext', 
							SocEcon,`socio', 
							CenDiv, `cd', 
							F,e(widstat))"
			}
		else{				
			global Xaddstat "addstat(Rail_b20,`rail_b20', 
							Hwy_b20,`hwy_b20', 
							Expl_b20,`expl_b20', 
							Rail,`rail', 
							Hwy,`hwy', 
							Expl,`expl', 
							pop80,`pop80', 
							pop90,`pop90', 
							emp83,`emp83', 
							emp93,`emp93', 
							hist pop,`pop20_70', 
							Geog,`geog', 
							GeogExt,`geog_ext', 
							SocEcon,`socio', 
							CenDiv,`cd', 
							F,e(widstat),
							J,e(jp))"
			}			
		end
******************************
*SHORTHAND NOTATIONS          
******************************
global population "l_pop70 l_pop60 l_pop50 l_pop40 l_pop30 l_pop20"  
global cen_div "div1 div2 div3 div4 div5 div6 div7 div8"
global employment "l_emp83 l_emp77"  
global geography	 "pc_aquifer_msa elevat_range_msa ruggedness_msa heating_dd cooling_dd"
global geography_ext "pc_aquifer_msa2 elevat_range_msa2 ruggedness_msa2 eleva_rug"
global socioeco "S_somecollege_80 l_mean_income seg1980_ghetto S_poor_80 Smanuf77" 

*local depvar "Dl_emp90"
local depvar "Dl_pop00"
*local depvar "Dl_pop00_90"
*local depvar "Dl_emp00_90"

use "$route/Data/Duranton_Turner_RES2012.dta",clear


* counter for columns in outreg file
local i=0

********************************** TABLE 1 *************************************
******************************* SUMMARY STATS **********************************
if 1==1 {
*quietly log using new_tables/table1, text replace

drop if rd_km_IH_83==0

gen  rd_km_IH_03pc = rd_km_IH_03/pop00*10000
gen  rd_km_IH_93pc = rd_km_IH_93/pop90*10000
gen  rd_km_IH_83pc = rd_km_IH_83/pop80*10000
gen  bus_pc = max_84bus/pop80*10000
gen emp03 = exp(l_emp03)
gen emp83 = exp(l_emp83)
gen  emp_g03 = (emp03/emp83)^(0.05)
gen  pop_g00 = (pop00/pop80)^(0.05)

sum 	emp83 emp03 emp_g03 pop80 pop00 pop_g00 l_emp83 Dl_emp03 ///
road1980 rd_km_IH_83 rd_km_IH_03 l_rd_km_IH_83 ///
	rd_km_IH_83pc rd_km_IH_03pc ///
	max_84bus bus_pc  ///
	pc_aquifer_msa elevat_range_msa ruggedness_msa cooling_dd heating_dd ///
	S_somecollege_80 S_poor_80 Smanuf77 ///
	hwy1947 rail1898 pix_pre1850

pwcorr l_rd_km_IH_83 l_hwy1947 l_rail1898 l_pix_pre1850


*quietly log close
}

*************************************************************************************
*************************************************************************************
*************************************************************************************
* CONFIRMED SAME RESULTS AS AUTHORS BUT NOTE HOW ANNUAL EMPLOYMENT GROWTH IS REPORTED
*************************************************************************************
*************************************************************************************
*************************************************************************************

************************ MAKE SUMMARY TABLE ************************************
estpost sum emp83 emp03 emp_g03 pop80 pop00 pop_g00 l_emp83 Dl_emp03 ///
road1980 rd_km_IH_83 rd_km_IH_03 l_rd_km_IH_83 ///
	rd_km_IH_83pc rd_km_IH_03pc ///
	max_84bus bus_pc  ///
	pc_aquifer_msa elevat_range_msa ruggedness_msa cooling_dd heating_dd ///
	S_somecollege_80 S_poor_80 Smanuf77 ///
	hwy1947 rail1898 pix_pre1850
	
esttab using "$route/tables/sumtab.tex", replace cells("mean sd")  
******************************* TABLE 2 ****************************************
****** OLS RESULTS
****** NOTE: LISTED AS TABLE 3 IN AUTHORS CODE

****** PANEL A

if 1==1 {

*quietly log using new_tables/table3a, text replace

local depvar "Dl_emp03"
local road "rd_km_IH_83"
local road2 "rd_km_IH_83"

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se "

reg `depvar' l_`road' l_emp83 if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   replace

reg `depvar' l_`road' l_emp83   $population if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83  $population  $geography if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population   $geography   $geography_ext $socioeco  if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'  append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext $socioeco $cen_div  if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_road1980 l_emp83   $population if `road2'>0, robust
outreg2 l_road1980  l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg Dl_pop00 l_`road' l_emp83   $population if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(Dl_pop00)  `instruct'   append

*log close
}

****** PANEL B
if 1==1 {

*quietly log using new_tables/table3b, text replace
local road "rd_km_IH_83"
local road2 "rd_km_IH_83"
local depvar "Dl_rd_km_IH_03"
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se " 
*local instruct2 "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))"

reg `depvar' l_`road' l_emp83 if `road2'>0, robust
outreg2 l_`road' l_emp83  using  "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83    $population if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83  $population  $geography if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population   $geography   $geography_ext $socioeco  if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'  append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext $socioeco $cen_div  if `road2'>0, robust
outreg2 l_`road' l_emp83 using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append

reg `depvar' l_road1980 l_emp83 $population if `road2'>0, robust
outreg2 l_road1980  l_emp83  using "$route/tables/table3author.tex", ctitle(`depvar')  `instruct'   append


*log close

}

********************************************************************************
************************** REPEAT TABLE 2 w/ ESTOUT ****************************
********************************************************************************
eststo clear
******* PANEL A
local depvar "Dl_emp03"
local road "rd_km_IH_83"
local road2 "rd_km_IH_83"

****** REGRESSIONS
reg `depvar' l_`road' l_emp83 if `road2'>0, robust
eststo TABLE2AC1

reg `depvar' l_`road' l_emp83   $population if `road2'>0, robust
eststo TABLE2AC2

reg `depvar' l_`road' l_emp83  $population  $geography if `road2'>0, robust
eststo TABLE2AC3

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext if `road2'>0, robust
eststo TABLE2AC4

reg `depvar' l_`road' l_emp83   $population   $geography   $geography_ext $socioeco  if `road2'>0, robust
eststo TABLE2AC5

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext $socioeco $cen_div  if `road2'>0, robust
eststo TABLE2AC6

reg `depvar' l_road1980 l_emp83   $population if `road2'>0, robust
eststo TABLE2AC7

reg Dl_pop00 l_`road' l_emp83   $population if `road2'>0, robust
eststo TABLE2AC8

***** MAKE TABLE
local gops      noconstant star(* 0.10 ** 0.05 *** 0.01) /// general options same for each panel
				fragment booktabs se r2 compress b(%5.3f) se(%5.3f)

//---PANEL A---//
//Latex code - different for each panel
local preheadA  "\begin{tabular}{l*{@M}{c}} \hline" //only need in first panel
local postheadA "\hline \multicolumn{@span}{l}{\textbf{Panel A: Employment or Population Growth}} \\"

*****OLS Output Redo:
esttab TABLE2AC1 TABLE2AC2 TABLE2AC3 TABLE2AC4 TABLE2AC5 TABLE2AC6 TABLE2AC7 TABLE2AC8 ///
		using "$route/tables/table2.tex", replace `gops' nomtitles ///
		prehead(`preheadA') posthead(`postheadA') ///
		keep(l_rd_km_IH_83 l_emp83 l_road1980) ///
		varlabels(l_rd_km_IH_83 "ln(Int. Hwy km_{83})" l_emp83 "ln(Emp_{83})" l_road1980 "ln(USGS maj. roads_{80})")

*** Issues with this table output **** esttab TABLE2AC1 TABLE2AC2 TABLE2AC3 TABLE2AC4 TABLE2AC5 TABLE2AC6 TABLE2AC7 TABLE2AC8 using "$route/tables/table3esttab.tex", replace `gops' nonumber prehead(`preheadA') posthead(`postheadA') keep (l_rd_km_IH_83 l_emp83 l_road1980) 

*esttab TABLE2AC1 TABLE2AC2 TABLE2AC3 TABLE2AC4 TABLE2AC5 TABLE2AC6 TABLE2AC7 TABLE2AC8 using "$route/tables/table3esttab.tex", replace keep (l_rd_km_IH_83 l_emp83 l_road1980) posthead("Panel A") label star(* 0.10 ** 0.05 *** 0.01) r2 nomtitle

****** PANEL B
local road "rd_km_IH_83"
local road2 "rd_km_IH_83"
local depvar "Dl_rd_km_IH_03"

****** REGRESSIONS
reg `depvar' l_`road' l_emp83 if `road2'>0, robust
eststo TABLE2BC1

reg `depvar' l_`road' l_emp83    $population if `road2'>0, robust
eststo TABLE2BC2

reg `depvar' l_`road' l_emp83  $population  $geography if `road2'>0, robust
eststo TABLE2BC3

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext if `road2'>0, robust
eststo TABLE2BC4

reg `depvar' l_`road' l_emp83   $population   $geography   $geography_ext $socioeco  if `road2'>0, robust
eststo TABLE2BC5

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext $socioeco $cen_div  if `road2'>0, robust
eststo TABLE2BC6

reg `depvar' l_road1980 l_emp83 $population if `road2'>0, robust
eststo TABLE2BC7

***** ADD PANEL B TO TABLE
*latex code
local postheadB "\hline \multicolumn{@span}{l}{\textbf{Panel B: Road Growth}} \\"

*panel B Tabel 2 Output
esttab TABLE2BC1 TABLE2BC2 TABLE2BC3 TABLE2BC4 TABLE2BC5 TABLE2BC6 TABLE2BC7 ///
	using "$route/tables/table2.tex", append keep(l_rd_km_IH_83 l_emp83 l_road1980) ///
	`gops' nomtitles nonumber varlabels(l_rd_km_IH_83 "ln(Int. Hwy km_{83})" l_emp83 "ln(Emp_{83})" l_road1980 "ln(USGS maj. roads_{80})") ///
	posthead(`postheadB')

*esttab TABLE2BC1 TABLE2BC2 TABLE2BC3 TABLE2BC4 TABLE2BC5 TABLE2BC6 TABLE2BC7 using "$route/tables/table3esttab.tex",  append `gops' nonumber nomtitle posthead(`postheadB') keep (l_rd_km_IH_83 l_emp83 l_road1980) 

*esttab TABLE2BC1 TABLE2BC2 TABLE2BC3 TABLE2BC4 TABLE2BC5 TABLE2BC6 TABLE2BC7 using "$route/tables/table3esttab.tex", append keep (l_rd_km_IH_83 l_emp83 l_road1980) posthead("Panel B") label star(* 0.10 ** 0.05 *** 0.01) r2 nomtitle nonumber


****************************** TABLE 3 *****************************************
******* IV RESULTS 
******* RUN AUTHORS CODE W/ LIML TO CONFIRM PAPER RESULTS
******* NOTE: TABLE 4 IN AUTHORS CODE

if 1==1 {

*quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

ivreg2  `depvar' l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(`depvar') `instruct'    replace
*eststo IV1

ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(`depvar') `instruct'    append
*eststo IV2

ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(`depvar') `instruct'    append
*eststo IV3

ivreg2  `depvar' l_emp83 $population $geography   $geography_ext (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(`depvar') `instruct'    append
*eststo IV4

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(`depvar') `instruct'    append
*eststo IV5

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(`depvar')  `instruct'    append
*eststo IV6

ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(`depvar') `instruct'    append
*eststo IV7

ivreg2  Dl_pop00 l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMA.xls", ctitle(Dl_pop00) `instruct'    append
*eststo IV8

*log close

}

************************************
*table 4b Changes in roads, IV      
************************************

if 1==1 {
*quietly log using new_tables/table4b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

ivreg2  `depvar'  l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outregreg2  l_`road' l_emp83 using "$r*outrege/tables/IVCONFIRMB.xls", ctitle(`depvar') `instruct'    replace

ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outregreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMB.xls", ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMB.xls", ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography   $geography_ext (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMB.xls", ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMB.xls", ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_`road' l_emp83 using "$route/tables/IVCONFIRMB.xls", ctitle(`depvar')  `instruct'    append

ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/IVCONFIRMB.xls", ctitle(`depvar')  `instruct'    append


*log close

}

********************************************************************************
************************ CONFIRMED SAME AS PAPER *******************************
********************************************************************************

***************************** REPEAT W/ 2SLS ***********************************
******* PANEL A

if 1==1 {

*quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

ivreg2  `depvar' l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(`depvar') `instruct'    replace
eststo IV1A

ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(`depvar') `instruct'    append
eststo IV2A

ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(`depvar') `instruct'    append
eststo IV3A

ivreg2  `depvar' l_emp83 $population $geography   $geography_ext (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(`depvar') `instruct'    append
eststo IV4A

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(`depvar') `instruct'    append
eststo IV5A

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(`depvar')  `instruct'    append
eststo IV6A

ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(`depvar') `instruct'    append
eststo IV7A

ivreg2  Dl_pop00 l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVA.xls", ctitle(Dl_pop00) `instruct'    append
eststo IV8A

*log close

}

******* PANEL B

if 1==1 {
*quietly log using new_tables/table4b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

ivreg2  `depvar'  l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVB.xls", ctitle(`depvar') `instruct'    replace
eststo IV1B


ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVB.xls", ctitle(`depvar') `instruct'    append
eststo IV2B


ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVB.xls", ctitle(`depvar') `instruct'    append
eststo IV3B


ivreg2  `depvar' l_emp83 $population $geography $geography_ext  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVB.xls", ctitle(`depvar') `instruct'    append
eststo IV4B


ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVB.xls", ctitle(`depvar') `instruct'    append
eststo IV5B


ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/ACTUALIVB.xls", ctitle(`depvar')  `instruct'    append
eststo IV6B

ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/ACTUALIVB.xls", ctitle(`depvar')  `instruct'    append
eststo IV7B

****Make Table 4 IV
*** Panel A
esttab IV1A IV2A IV3A IV4A IV5A IV6A IV7A IV8A ///
		using "$route/tables/table3IV.tex", replace `gops' nomtitles ///
		prehead(`preheadA') posthead(`postheadA') ///
		keep(l_rd_km_IH_83 l_emp83 l_road1980) ///
		varlabels(l_rd_km_IH_83 "ln(Int. Hwy km_{83})" l_emp83 "ln(Emp_{83})" l_road1980 "ln(USGS maj. roads_{80})")

***Panel B
esttab TABLE2BC1 TABLE2BC2 TABLE2BC3 TABLE2BC4 TABLE2BC5 TABLE2BC6 TABLE2BC7 ///
	using "$route/tables/table3IV.tex", append keep(l_rd_km_IH_83 l_emp83 l_road1980) ///
	`gops' nomtitles nonumber varlabels(l_rd_km_IH_83 "ln(Int. Hwy km_{83})" l_emp83 "ln(Emp_{83})" l_road1980 "ln(USGS maj. roads_{80})") ///
	posthead(`postheadB')

*log close

}

************************** CONFIRMED SIMILAR RESULTS ***************************


********************************************************************************
*************** REPEAT 2SLS FOR THE 4 CENSUS REGION SUBSAMPLES *****************
********************************************************************************

********* BRING IN REGIONAL DATA
clear 

import excel "$route/Data/replication_region_add_on.xlsx", sheet("Sheet1") firstrow

rename RegionBasedonLocationofMSA Region

save "$route/Data/Regional_MSA.dta", replace

clear

******* Merge the Data
use "$route/Data/Duranton_Turner_RES2012.dta", clear

merge 1:1 msa msa_name using "$route/Data/Regional_MSA.dta"

save "$route/Data/ReplicationRegion.dta", replace

encode Region, gen(census_region)
order Region census_region
tab census_region, gen(region_dmy)
order Region census_region region_dmy*

save "$route/Data/ReplicationRegion.dta", replace

********************************************************************************
********************************* SOUTH 2SLS ***********************************
********************************************************************************


if 1==1 {

*quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

*ivreg2  `depvar' l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography   $geography_ext (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  Dl_pop00 l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVA.xls", ctitle(Dl_pop00) `instruct'    append

*log close

}

******* PANEL B

if 1==1 {
*quietly log using new_tables/table4b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

*ivreg2  `depvar'  l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVB.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography $geography_ext  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/SOUTHIVB.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/SOUTHIVB.xls", ctitle(`depvar')  `instruct'    append


*log close

}

********************************************************************************
********************************* MIDWEST 2SLS *********************************
********************************************************************************

if 1==1 {

*quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

*ivreg2  `depvar' l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography   $geography_ext (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  Dl_pop00 l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVA.xls", ctitle(Dl_pop00) `instruct'    append

*log close

}

******* PANEL B

if 1==1 {
*quietly log using new_tables/table4b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

*ivreg2  `depvar'  l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVB.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography $geography_ext  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/MIDWESTIVB.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/MIDWESTIVB.xls", ctitle(`depvar')  `instruct'    append


*log close

}


********************************************************************************
******************************** NORTHEAST 2SLS ********************************
********************************************************************************

if 1==1 {

*quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

*ivreg2  `depvar' l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVA.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography   $geography_ext (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVA.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/NEIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  Dl_pop00 l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVA.xls", ctitle(Dl_pop00) `instruct'    append

*log close

}

******* PANEL B

if 1==1 {
*quietly log using new_tables/table4b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

*ivreg2  `depvar'  l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVB.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography $geography_ext  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/NEIVB.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/NEIVB.xls", ctitle(`depvar')  `instruct'    append


*log close

}

********************************************************************************
********************************** WEST 2SLS ***********************************
********************************************************************************

if 1==1 {

*quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

*ivreg2  `depvar' l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVA.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1, robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography   $geography_ext (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVA.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/WESTIVA.xls", ctitle(`depvar') `instruct'    append

*ivreg2  Dl_pop00 l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVA.xls", ctitle(Dl_pop00) `instruct'    append

*log close

}

******* PANEL B

if 1==1 {
*quietly log using new_tables/table4b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

*ivreg2  `depvar'  l_emp83 (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVB.xls", ctitle(`depvar') `instruct'    replace

*ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population $geography $geography_ext  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVB.xls", ctitle(`depvar') `instruct'    append

*ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_`road' l_emp83 using "$route/tables/WESTIVB.xls", ctitle(`depvar')  `instruct'    append

*ivreg2  `depvar' l_emp83 $population (l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1,  robust
*outreg2  l_road1980 l_emp83 using "$route/tables/WESTIVB.xls", ctitle(`depvar')  `instruct'    append


*log close

}

********************************************************************************
************************* USE ESTOUT FOR THE EXTENSION *************************
********************************************************************************
******** Employment
eststo clear

*quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"


***SOUTH
ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1, robust
eststo Southemp

***Midwest
ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1, robust
eststo MWemp

***Northeast
ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1, robust
eststo NEemp

***West
ivreg2  `depvar' l_emp83 $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1, robust
eststo Westemp

esttab Southemp MWemp NEemp Westemp using "$route/tables/Employmentextension.tex", replace keep (l_rd_km_IH_83 l_emp83) label star(* 0.10 ** 0.05 *** 0.01) r2 nonumber


******** Road Growth
eststo clear
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

***SOUTH
ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy3==1, robust
eststo Southroad

***Midwest
ivreg2  `depvar' l_emp83 $population  $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy1==1, robust
eststo MWroad

***Northeast
ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy2==1, robust
eststo NEroad

***West
ivreg2  `depvar' l_emp83 $population $geography (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0 & region_dmy4==1, robust
eststo Westroad

esttab Southroad MWroad NEroad Westroad using "$route/tables/Employmentextension.tex", replace keep (l_rd_km_IH_83 l_emp83) label star(* 0.10 ** 0.05 *** 0.01) r2 nonumber

***SUMMARIZE MIDWEST CITIES
sum pop80
sum pop80 if region_dmy1==1











