/**********************************************************************************************
cull_welfare.do

Subroutine to 
1 make variables need for regressions 
2 drop everything not needed.
3 run two regressions and save coefficients as data;

************************************************************************************************/


******************************;
* SET UP                      ;
******************************;

#delimit;
clear;

set matsize 800;
set memory 200m;
set more 1;

******************************;
*SHORTHAND NOTATIONS          ;
******************************;
global population "l_pop70 l_pop60 l_pop50 l_pop40 l_pop30 l_pop20"  ;
global cen_div "div1 div2 div3 div4 div5 div6 div7 div8";
global employment "l_emp83 l_emp77"  ;
global geography	 "pc_aquifer_msa elevat_range_msa ruggedness_msa heating_dd cooling_dd";
global geography_ext "pc_aquifer_msa2 elevat_range_msa2 ruggedness_msa2 eleva_rug";
global socioeco "S_somecollege_80 l_mean_income seg1980_ghetto S_poor_80 Smanuf77" ;

local depvar "Dl_pop00";

***********************************************;
*ADDITIONS OF AADT AND OTHER CHANGES BY GD     ;
***********************************************;

use Duranton_Turner_RES2012.dta,clear;
keep  
	msa  g_exp00_80 g_exp00_90 g_exp90_80 g_exp97_77 g_exp97_87 g_exp87_77 l_aadt_IH_83 l_aadt_IH_93 l_aadt_IH_03  l_aadt_IHU_83 l_aadt_IHU_93 l_aadt_IHU_03  l_aadt_MRU_83 l_aadt_MRU_93 l_aadt_MRU_03 mean_income_80 pc_aquifer_msa elevat_range_msa ruggedness_msa pix1528 pix1675 pix1800 pix1820 pix1835 pix1528_b20 pix1675_b20 pix1800_b20 pix1820_b20 pix1835_b20 rd_km_MRU_83 rd_km_IH_83 l_ln_km_IH_83 l_ln_km_IH_93 l_ln_km_IH_03 l_rd_km_IH_83 l_rd_km_IH_93 l_rd_km_IH_03 l_pop20 l_pop80 l_emp83 l_emp03 l_pop70 l_pop60 l_pop50 l_pop40 l_pop30 l_pop20
	l_hwy1947 l_rail1898;
sort msa;

gen mean_income = mean_income_80;
gen Dl_emp03=l_emp03-l_emp83;

******************************;
*CREATION OF NEW VARIABLES    ;
******************************;

*drop two problem msas;
*casper wy, lots of employment growth, not much pop, lots of rail, little hwy1947;
drop if msa==1350;
*Lawton OK.  No rail or hwy1947 but lots of highways;
*drop if msa==4200;

gen pc_aquifer_msa2	=  pc_aquifer_msa*pc_aquifer_msa;
gen elevat_range_msa2	=  elevat_range_msa*elevat_range_msa;
gen ruggedness_msa2 	=  ruggedness_msa*ruggedness_msa;
gen eleva_rug 		=  ruggedness_msa*elevat_range_msa;

gen pix_pre1820		=	pix1528+pix1675+pix1800;
gen pix_pre1820_b20	=	pix1528_b20+pix1675_b20+pix1800_b20;
gen pix_pre1850		=	pix1528+pix1675+pix1800+pix1820+pix1835;
gen pix_pre1850_b20	=	pix1528_b20+pix1675_b20+pix1800_b20+pix1820_b20+pix1835_b20;
gen all_road_83 	=  	rd_km_MRU_83 +  rd_km_IH_83;
gen l_all_road_83 	=  	log(rd_km_MRU_83 +  rd_km_IH_83);
foreach var in 	"pix_pre1850" 
		"pix_pre1820"
			{;
			gen l_`var'=log(`var'+1);
			gen l_`var'_b20=log(`var'_b20 +1);
		};

gen l_mean_income = log(mean_income);		
gen Dl_rd_km_IH_03 =  l_rd_km_IH_03 - l_rd_km_IH_83;
gen Dl_pop80_20 =  l_pop80 -  l_pop20;


************************************;
*table 3 Main IV column 2;
************************************;
*drop msa's missing 83IH to be consistent with regressions samples;
keep if rd_km_IH_83!=. & rd_km_IH_83!=0;

local depvar "Dl_emp03";
local road "rd_km_IH_83";

keep msa l_pop80 Dl_emp03 l_emp83 l_pop80  $population   l_`road' l_hwy1947 l_rail1898 l_pix_pre1850 Dl_rd_km_IH_03 rd_km_IH_83;
drop if msa==.;
count;
ivreg2  Dl_emp03  
	l_emp83   $population 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0, liml robust;

predict Dl_emp03_hat;
	
matrix list e(b);
count;
matrix b =get(_b);
count;
local i=0;
foreach var in      l_rd_km_IH_83         
		    l_emp83           
			{;
		local i = `i'+1;
		global x = b[1,`i'];
		count;
		gen b_`var'=$x;
		label var b_`var' "emp coef for `var'";
		};

gen Dl_emp_const= Dl_emp03_hat - (b_l_rd_km_IH_83 * l_rd_km_IH_83) - (b_l_emp83 * l_emp83);		
label var Dl_emp_const "constant part of emp regression";
		
************************************;
*table 3 Changes in roads, IV  Column 2    ;
************************************;

local depvar "Dl_rd_km_IH_03";
local road "rd_km_IH_83";


ivreg2  Dl_rd_km_IH_03  
	l_emp83  $population 
	(l_`road' = l_hwy1947 l_rail1898 l_pix_pre1850)
	if `road'>0, liml robust;

predict Dl_rd_km_IH_03_hat;
	
matrix list e(b);
count;
matrix c =get(_b);
count;
local i=0;
foreach var in      l_rd_km_IH_83         
		    l_emp83           
			{;
		local i = `i'+1;
		global x = c[1,`i'];
		count;
		gen c_`var'=$x;
		label var c_`var' "road coef for `var'";
		};
		
gen Dl_rd_km_const = Dl_rd_km_IH_03_hat - (c_l_rd_km_IH_83 * l_rd_km_IH_83) - (c_l_emp83 * l_emp83);		
label var Dl_rd_km_const "constant part of road regression";

drop  rd_km_IH_83 l_pop20-l_pop70 l_hwy1947-l_rail1898 l_pix* Dl_emp03 Dl_rd_km_IH_03 Dl_emp03_hat  Dl_rd_km_IH_03_hat;
order msa   l_pop80  l_emp83  l_rd_km_IH_83 Dl_emp_const Dl_rd_km_const b_l_rd_km_IH_83 b_l_emp83 c_l_rd_km_IH_83 c_l_emp83;

sum;
capture erase temp.dta;
exit;
