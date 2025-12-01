****************
*** ECON 582 Replication Study
*** Joey Nolan and Connor Lewis
*** 5DEC25
****************

/**********************************************************************************************
Durnanton_Turner_RES2012_main.do

Final tables for Duranton and Turner RES 2012.

You will need the stata `outreg2' and `ivreg2' command to run this program

Note that output file names do not correspond perfectly to the table numbers in the paper.


MT Dec 2011

************************************************************************************************/


******************************
* SET UP                      
******************************


clear

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

use Duranton_Turner_RES2012.dta,clear


* counter for columns in outreg file
local i=0


******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 1
*Descriptive stats
************************************

if 1==1 {
quietly log using "log", text replace

drop if rd_km_IH_83==0

gen  rd_km_IH_03pc = rd_km_IH_03/pop00*10000
gen  rd_km_IH_93pc = rd_km_IH_93/pop90*10000
gen  rd_km_IH_83pc = rd_km_IH_83/pop80*10000
gen  bus_pc = max_84bus/pop80*10000
gen emp03 = exp(l_emp03)
gen emp83 = exp(l_emp83)
gen  emp_g03 = (emp03/emp83)^(0.05)
gen  pop_g00 = (pop00/pop80)^(0.05)

sum 	emp83 emp03 emp_g03 pop80 pop00 pop_g00 l_emp83 Dl_emp03
	road1980 rd_km_IH_83 rd_km_IH_03 l_rd_km_IH_83
	rd_km_IH_83pc rd_km_IH_03pc
	max_84bus bus_pc  
	pc_aquifer_msa elevat_range_msa ruggedness_msa cooling_dd heating_dd 
	S_somecollege_80 S_poor_80 Smanuf77
	hwy1947 rail1898 pix_pre1850

pwcorr l_rd_km_IH_83 l_hwy1947 l_rail1898 l_pix_pre1850


quietly log close
}


******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*NB: table numbers here don't quite match paper -- first stage table is out of order
*table 2
*First stage
************************************
if 1==1 {

quietly log using new_tables/table2, text replace


local road "rd_km_IH_83"
local i=0

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se " 

reg l_`road' 
	l_hwy1947 l_rail1898 l_pix_pre1850 l_emp83   
	if `road'>0, robust
test l_hwy1947  l_rail1898 l_pix_pre1850
outreg2  using new_tables/table2.xls, ctitle(`road') addstat(F,r(F)) `instruct'  replace

reg l_`road' 
	l_hwy1947 l_rail1898 l_pix_pre1850 l_emp83  $population 
	if `road'>0, robust
test l_hwy1947  l_rail1898 l_pix_pre1850
outreg2  using new_tables/table2.xls, ctitle(`road') addstat(F,r(F)) `instruct'  append

reg l_`road' 
	l_hwy1947 l_rail1898 l_pix_pre1850 l_emp83  $population  $geography $socioeco  $cen_div
	if `road'>0, robust
test l_hwy1947  l_rail1898 l_pix_pre1850
outreg2  using new_tables/table2.xls, ctitle(`road') addstat(F,r(F)) `instruct'  append

reg l_`road' 
	l_hwy1947 l_emp83  $population   
	if `road'>0, robust
test l_hwy1947
outreg2  using new_tables/table2.xls, ctitle(`road') addstat(F,r(F)) `instruct'  append

reg l_`road' 
	l_rail1898 l_emp83  $population   
	if `road'>0, robust
test l_rail1898
outreg2  using new_tables/table2.xls, ctitle(`road') addstat(F,r(F)) `instruct'  append

reg l_`road' 
	l_pix_pre1850 l_emp83   $population  
	if `road'>0, robust
test l_pix_pre1850
outreg2  using new_tables/table2.xls, ctitle(`road') addstat(F,r(F)) `instruct'  append

reg l_road1980 
	l_hwy1947 l_rail1898 l_pix_pre1850 l_emp83  $population
	if `road'>0, robust
test l_hwy1947  l_rail1898 l_pix_pre1850
outreg2  using new_tables/table2.xls, ctitle(`road') addstat(F,r(F)) `instruct'  append

log close

}

******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 3a
*Main City growth OLS
************************************

if 1==1 {

quietly log using new_tables/table3a, text replace

local depvar "Dl_emp03"
local road "rd_km_IH_83"
local road2 "rd_km_IH_83"

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se " 

reg `depvar' l_`road' l_emp83 
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3a.xls, ctitle(`depvar')  `instruct'   replace

reg `depvar' l_`road' l_emp83   $population 
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3a.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83  $population  $geography   
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3a.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext 
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3a.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population   $geography   $geography_ext $socioeco  
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3a.xls, ctitle(`depvar')  `instruct'  append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext $socioeco $cen_div  
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3a.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_road1980 l_emp83   $population   
	if `road2'>0, robust
outreg2 l_road1980  l_emp83 using new_tables/table3a.xls, ctitle(`depvar')  `instruct'   append

reg Dl_pop00 l_`road' l_emp83   $population   
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3a.xls, ctitle(Dl_pop00)  `instruct'   append

log close
}

************************************
*table 3b --- Main road growth, OLS  
************************************

if 1==1 {

quietly log using new_tables/table3b, text replace
local road "rd_km_IH_83"
local road2 "rd_km_IH_83"
local depvar "Dl_rd_km_IH_03"
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se " 
*local instruct2 "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))"

reg `depvar' l_`road' l_emp83 
	if `road2'>0, robust
outreg2 l_`road' l_emp83  using new_tables/table3b.xls, ctitle(`depvar')  `instruct'   replace

reg `depvar' l_`road' l_emp83    $population 
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3b.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83  $population  $geography   
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3b.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext 
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3b.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_`road' l_emp83   $population   $geography   $geography_ext $socioeco  
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3b.xls, ctitle(`depvar')  `instruct'  append

reg `depvar' l_`road' l_emp83   $population  $geography   $geography_ext $socioeco $cen_div  
	if `road2'>0, robust
outreg2 l_`road' l_emp83 using new_tables/table3b.xls, ctitle(`depvar')  `instruct'   append

reg `depvar' l_road1980 l_emp83 $population   
	if `road2'>0, robust
outreg2 l_road1980  l_emp83  using new_tables/table3b.xls, ctitle(`depvar')  `instruct'   append


log close

}

******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 4a
*Main IV Demp
************************************

if 1==1 {

quietly log using new_tables/table4a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

ivreg2  `depvar' l_emp83 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4a.xls, ctitle(`depvar') `instruct'    replace

ivreg2  `depvar' l_emp83 $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography   $geography_ext 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4a.xls, ctitle(`depvar')  `instruct'    append

ivreg2  `depvar' l_emp83 $population    
	(l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_road1980 l_emp83 using new_tables/table4a.xls, ctitle(`depvar') `instruct'    append

ivreg2  Dl_pop00 l_emp83 $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4a.xls, ctitle(Dl_pop00) `instruct'    append

log close

}

************************************
*table 4b Changes in roads, IV      
************************************

if 1==1 {
quietly log using new_tables/table4b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

ivreg2  `depvar'  l_emp83   
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4b.xls, ctitle(`depvar') `instruct'    replace

ivreg2  `depvar' l_emp83 $population 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography   
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography   $geography_ext 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table4b.xls, ctitle(`depvar')  `instruct'    append

ivreg2  `depvar' l_emp83 $population 
	(l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_road1980 l_emp83 using new_tables/table4b.xls, ctitle(`depvar')  `instruct'    append


log close

}

******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*TABLE 5 --- ENDOGENEITY OF ROADS   
************************************

if 1==1 {

quietly log using new_tables/table5, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se " 
local instruct2 "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

gen Droadcons= log(Sroadcons93 + Sroadcons97)-log(Sroadcons83 + Sroadcons87)

replace Sroadcons = 100*Sroadcons

local road "rd_km_IH_83"

rename Sroadcons Roadcon
gen Sroadcons = log(Roadcon)

*Share of employment in road construction with more controls
reg  Sroadcons Dl_pop00 l_pop80 $geography 
	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(SRC_more_controls) `instruct' replace 

*Share of employment in road construction with more controls
reg  Sroadcons Dl_pop00 l_pop80 $geography $cen_div
	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(SRC_more_controls) `instruct' append 

*Share of employment in road construction with even more controls
reg  Sroadcons Dl_pop00 l_pop80 $population $geography $cen_div
	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(SRC_complete_controls) `instruct'  append 

*Share of employment in road construction with complete controls
reg  Sroadcons Dl_pop00 l_pop80  $population $geography $cen_div Sbuildcons 
	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(SRC_with_build_cons) `instruct'  append 

*Change in the Share of employment in road construction with more controls
reg  Droadcons Dl_pop00 l_pop80 $geography 
	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(DRC_more_controls) `instruct' append 

*Change in the Share of employment in road construction with more controls
reg  Droadcons Dl_pop00 l_pop80 $geography $cen_div
	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(DRC_more_controls) `instruct' append 

*Change in the Share of employment in road construction with even more controls
reg  Droadcons Dl_pop00 l_pop80 $population $geography $cen_div
	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(DRC_complete_controls) `instruct'  append 

*Change in the Share of employment in road construction with complete controls
reg  Droadcons Dl_pop00 l_pop80 $population $geography $cen_div Sbuildcons 
 	if `road'>0, robust
outreg2 using new_tables/table5.xls, ctitle(DRC_with_build_cons) `instruct'  append 


log close
}


******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 7a
*Main IV Demp -- GMM
************************************

if 1==1 {

quietly log using new_tables/table7a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
*local road "ln_km_IH_83"

*keep if l_hwy1947>0

ivreg2  `depvar' l_emp83 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7a.xls, ctitle(`depvar') `instruct'    replace

ivreg2  `depvar' l_emp83 $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography   $geography_ext 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7a.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7a.xls, ctitle(`depvar')  `instruct'    append

ivreg2  `depvar' l_emp83 $population    
	(l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_road1980 l_emp83 using new_tables/table7a.xls, ctitle(`depvar') `instruct'    append

ivreg2  Dl_pop00 l_emp83 $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7a.xls, ctitle(Dl_pop00) `instruct'    append

log close

}

************************************
*table 7b Changes in roads, IV      
************************************

if 1==1 {
quietly log using new_tables/table7b, text replace
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 
local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"

ivreg2  `depvar'  l_emp83   
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7b.xls, ctitle(`depvar') `instruct'    replace

ivreg2  `depvar' l_emp83 $population 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography   
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population $geography   $geography_ext 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7b.xls, ctitle(`depvar') `instruct'    append

ivreg2  `depvar' l_emp83 $population  $geography   $geography_ext $socioeco $cen_div 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_`road' l_emp83 using new_tables/table7b.xls, ctitle(`depvar')  `instruct'    append

ivreg2  `depvar' l_emp83 $population 
	(l_road1980 = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,gmm  robust
outreg2  l_road1980 l_emp83 using new_tables/table7b.xls, ctitle(`depvar')  `instruct'    append


log close

}

******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 9a
*Main IV -- Demp robustness to different instruments
************************************

if 1==1 {

quietly log using new_tables/table9a, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_emp03"
local road "rd_km_IH_83"
* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table9a.xls, ctitle(`depvar') `instruct'   replace

* prefered specification from table 3, different instruments
ivreg2  `depvar' 
	l_emp83   $population (l_`road'  = l_hwy1947) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9a.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road'   = l_rail1898)	if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9a.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road'   = l_pix_pre1850) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9a.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population  (l_`road' = l_hwy1947 l_rail1898) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9a.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road' = l_hwy1947 l_pix_pre1850) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9a.xls, ctitle(`depvar')  `instruct' append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road' = l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9a.xls, ctitle(`depvar') `instruct'  append

log close

}

******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 8b
*Main IV -- DRoads robustness to different instruments
************************************

if 1==1 {

quietly log using new_tables/table9b, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local depvar "Dl_rd_km_IH_03"
local road "rd_km_IH_83"
* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population  (l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
outreg2  l_`road' l_emp83 using new_tables/table9b.xls, ctitle(`depvar') `instruct'   replace

* prefered specification from table 3, different instruments
ivreg2  `depvar' 
	l_emp83   $population  (l_`road'  = l_hwy1947) 	if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9b.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population  (l_`road'   = l_rail1898) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9b.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road'   = l_pix_pre1850)  if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9b.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population  (l_`road' = l_hwy1947 l_rail1898) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9b.xls, ctitle(`depvar') `instruct'   append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road' = l_hwy1947 l_pix_pre1850) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9b.xls, ctitle(`depvar')  `instruct' append

* prefered specification from table 3
ivreg2  `depvar' 
	l_emp83   $population (l_`road' = l_rail1898 l_pix_pre1850) if `road'>0,liml  robust
outreg2  l_`road' l_emp83  using new_tables/table9b.xls, ctitle(`depvar') `instruct'  append

log close

}

******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 9
*Main IV -- Demp robustness to changes in variables
************************************

if 1==1 {

quietly log using new_tables/table9, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))" 

local road "rd_km_IH_83"

* prefered specification from table 4, Dl_emp80_90
ivreg2  Dl_emp93 
	l_emp83  $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' using new_tables/table9.xls, ctitle(Dl_emp93) `instruct'   replace

* prefered specification from table 4, Dl_emp90_00
ivreg2  Dl_emp93_03
	l_emp93  l_pop80 $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_`road' using new_tables/table9.xls, ctitle(Dl_emp93_03) `instruct'   append

* prefered specification from table 4, Dl_emp90_00 and 1990 roads!
ivreg2  Dl_emp93_03 
	 l_emp93 l_pop80 $population   
	(l_rd_km_IH_93 = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0,liml  robust
outreg2  l_rd_km_IH_93  using new_tables/table9.xls, ctitle(Dl_emp93_03) `instruct'   append

* prefered specification from table 4, MSA fringe geography and instruments
ivreg2  Dl_emp03
	l_emp83  $population  
	(l_`road' = l_hwy1947_b20 l_rail1898_b20 l_pix_pre1850_b20)
	if `road'>0,liml  robust
outreg2  l_`road' using new_tables/table9.xls, ctitle(Dl_emp03) `instruct'   append

* prefered specification from table 4, split sample
ivreg2  Dl_emp03 
	l_emp83 $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0 & pop80>300000,liml  robust
outreg2  l_`road' using new_tables/table9.xls, ctitle(Dl_emp03) `instruct'  append

* prefered specification from table 4, split sample
ivreg2  Dl_emp03 
	l_emp83 $population  
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0 & pop80<=300000,liml  robust
outreg2  l_`road' using new_tables/table9.xls, ctitle(Dl_emp03) `instruct'   append

log close

}


******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 10 --- LONG RUN               
************************************

if 1==1 {

quietly log using new_tables/table10, text replace

local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se " 
local if_clause "if pop20>=100000"

reg  Dl_pop20_00 l_pop20 l_rail1898 `if_clause' ,robust
outreg2 using new_tables/table10.xls, ctitle(rail OLS)  `instruct'  replace 

reg  Dl_pop20_00 l_pop20 $geography  l_rail1898 `if_clause' ,robust
outreg2 using new_tables/table10.xls, ctitle(rail OLS)  `instruct'  append 

reg  Dl_pop20_00 l_pop20 $geography $cen_div l_rail1898  `if_clause',robust
outreg2 using new_tables/table10.xls, ctitle(rail OLS)  `instruct'   append 

reg  Dl_pop20_00 l_pop20 $geography $cen_div $geography_ext l_rail1898  `if_clause',robust
outreg2 using new_tables/table10.xls, ctitle(rail OLS)  `instruct'   append 

* IV is too weak

log close

}


******************************************************************** 
******************************************************************** 
******************************************************************** 
************************************
*table 11 --- NEIGHBORS             
************************************

if 1==1 {

quietly log using new_tables/table11, text replace
local road "rd_km_IH_83"
local instruct "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se " 
local instruct2 "tex(pr) tdec(2) rdec(2) auto(2) symbol($^a$,$^b$,$^c$) se addstat(Overid,e(jp),First stage F, e(widstat))"

gen l_nbr_hwy1947 = log(1+nbr_hwy1947)
gen l_nbr_rail1898 = log(1+ nbr_rail1898)
gen l_nbr_pix_pre1850 = log(1+ pix_pre1850)

*OLS, pop
reg  Dl_emp03 l_emp83  $population   l_nbr_`road' l_`road' if `road'>0, robust
outreg2 l_nbr_`road' l_`road' l_emp83  using new_tables/table11.xls, ctitle(OLS)  `instruct'   replace 

*OLS, pop
reg  Dl_emp03 l_emp83  $population   l_nbr_gravityIH83 l_`road' if `road'>0, robust
outreg2  l_nbr_gravityIH83  l_`road' l_emp83  using new_tables/table11.xls, ctitle(OLS)  `instruct'   append 

*IV  pop, 3 instruments		
ivreg2  Dl_emp03 l_emp83  $population  l_nbr_`road' (l_`road' =  l_rail1898  l_hwy1947 l_pix_pre1850) if `road'>0, first liml robust
outreg2 l_nbr_`road'  l_`road' l_emp83 using new_tables/table11.xls, ctitle(Dl_emp03 IV-3inst)  `instruct2'   append

*IV  pop, 3 instruments		
ivreg2  Dl_emp03 l_emp83  $population   l_nbr_gravityIH83 (l_`road' =  l_rail1898  l_hwy1947 l_pix_pre1850) if `road'>0, first liml robust
outreg2 l_nbr_gravityIH83  l_`road' l_emp83  using new_tables/table11.xls, ctitle(Dl_emp03 IV-3inst)  `instruct2'   append

*IV  pop, 6 instruments		
ivreg2  Dl_emp03 l_emp83  $population  (l_nbr_`road' l_`road' =  l_rail1898  l_hwy1947 l_pix_pre1850 l_nbr_hwy1947 l_nbr_rail1898 l_nbr_pix_pre1850) if `road'>0, first liml robust
outreg2 l_nbr_`road' l_`road' l_emp83  using new_tables/table11.xls, ctitle(Dl_emp03 IV-6inst)  `instruct2'   append

*IV  pop, 6 instruments		
ivreg2  Dl_emp03 l_emp83  $population  (l_nbr_gravityIH83 l_`road' =  l_rail1898  l_hwy1947 l_pix_pre1850 l_nbr_hwy1947 l_nbr_rail1898 l_nbr_pix_pre1850) if `road'>0, first liml robust
outreg2 l_nbr_gravityIH83  l_`road' l_emp83  using new_tables/table11.xls, ctitle(Dl_emp03 IV-6inst)  `instruct2'   append

*IV  complete, 6 instruments		
ivreg2  Dl_emp03 l_emp83  $population $geography  $socioeco $cen_div  (l_nbr_`road' l_`road' =  l_rail1898  l_hwy1947 l_pix_pre1850 l_nbr_hwy1947 l_nbr_rail1898 l_nbr_pix_pre1850) if `road'>0, first liml robust
outreg2 l_nbr_`road' l_`road' l_emp83 using new_tables/table11.xls, ctitle(Dl_emp03 IV-6inst)  `instruct2'   append

*IV  complete, 6 instruments		
ivreg2  Dl_emp03 l_emp83  $population $geography  $socioeco $cen_div  (l_nbr_gravityIH83 l_`road' =  l_rail1898  l_hwy1947 l_pix_pre1850 l_nbr_hwy1947 l_nbr_rail1898 l_nbr_pix_pre1850) if `road'>0, first liml robust
outreg2 l_nbr_gravityIH83  l_`road' l_emp83 using new_tables/table11.xls, ctitle(Dl_emp03 IV-3inst)  `instruct2'   append

log close
}


exit
