
clear all
set more off
**** Convert files to Stata Format
	
	* Convert drinkin water systems files to stata format
	import delimited "rawdata/active_surface_water_systems.csv", clear
	save "rawdata/active_surface_water_systems.dta", replace

	import delimited "rawdata/active_surface_water_intakes.csv", clear
	save "rawdata/active_surface_water_intakes.dta", replace

	import delimited "rawdata/active_ground_water_systems.csv", clear
	save "rawdata/active_ground_water_systems.dta", replace

	import delimited "rawdata/active_surface_water_intakes_impact_20201116.csv", clear
	save "rawdata/active_surface_water_intakes_impact_20201116.dta", replace

	* Convert the PWS Median Household Income Information to stata format	
	import excel "rawdata/PWS_with_2010_MHI_id.xlsx", sheet("PWS_with_2010_MHI_id") firstrow clear
	rename PblcSyN system_nam
	rename MHI_2010 mhi_2010
	rename Wt_S_ID number0
	sort number0
	save  "rawdata/PWS_with_2010_MHI.dta", replace

	* Importing source ratio data for PWS with prin water source GU and SW (Surface PWS)
	import excel "rawdata/SurfaceWaterSystems 11-17-20.xlsx", sheet("SurfaceWaterSystems") firstrow case(lower) clear
	
	gen clean_no=strtrim(number0)
	drop number0
	rename clean_no number0
	gen surface_pws=1
	foreach var in surf_wtr_ratio surf_wtr_pur_ratio grnd_wtr_udi_ratio grnd_wtr_udi_purch {
		rename `var' `var'_if_spws
	}
	
	keep number0 surf_wtr_ratio surf_wtr_pur_ratio grnd_wtr_udi_ratio grnd_wtr_udi_purch surface_pws
	gen surface_ratio_if_spws=surf_wtr_ratio+surf_wtr_pur_ratio+grnd_wtr_udi_ratio+grnd_wtr_udi_purch
	save data/source_ratio_surface_pws.dta, replace

	* Importing surface purcahse data for PWS with prin water source SW and SWP
	import excel "rawdata/PurchaserData SW 11-17-20.xlsx", sheet("PurchaserData") firstrow case(lower) clear
	drop if pwsid==""
	gen clean_no=strtrim(pwsid)
	drop pwsid
	rename clean_no number0
	drop watersystemname
		
		
	gen clean_no=strtrim(sellerpwsid)
	drop sellerpwsid
	rename clean_no seller_number0_	
	rename sellerwatersystemname seller_system_name_
	rename sellerpop seller_pop_
	rename purchaserfacilityactivitystat surfacepurchaser_status
	
	order number0 surfacepurchaser_status  seller_number0 seller_system_name seller_pop
	keep number0 surfacepurchaser_status  seller_number0 seller_system_name seller_pop
	sort number0

	
	bysort number0: gen seller_num=_n
	reshape wide seller_number0_ seller_system_name_ seller_pop_, i(number0) j(seller_num) 
	
	* SWP system NM3544926 buys from another SWP water system, NM3500826 . Hence, we substitute SWP system NM3544926' sellers for the sellers used by NM3500826.
	replace seller_number0_1="NM3505126" if number0=="NM3544926"
	replace seller_number0_2="NM3502826" if number0=="NM3544926"
	replace seller_system_name_1="SANTA FE WATER SYSTEM (CITY OF)" if number0=="NM3544926"
	replace seller_system_name_2="BUCKMAN REGIONAL WATER TREATMENT PLANT" if number0=="NM3544926"
	replace seller_pop_1=78247 if number0=="NM3544926"
	replace seller_pop_2=0 if number0=="NM3544926"

	replace seller_number0_1="" if number0=="NM3501019"
	replace seller_system_name_1="" if number0=="NM3501019"
	save data/surface_purchaser_info_surface_pws.dta, replace	

*** Reshape drinking water system files and aggregate variables to have only one entry per pws


    *Aggregating active surface water systems information to have one entry per surface water system
		use rawdata/active_surface_water_systems.dta, clear
		gen has_nmdwb_data="Yes"
		* Creating an indicator to select only one observation per system
		bysort number0: gen unique_pws=_n==1

		* Checking number of values per system for system variables. 
		* All should have numpersys_`var' be equal to 1 except for water_type that can be 2 if the water system has GU and SW
		foreach var in system_nam owner_type d_prin_cit d_prin_cnt d_fed_prim d_populati d_ttl_stor d_pws_fed_ water_type {
			bysort number0 `var': gen unqpersys_`var'=_n==1
			bysort number0: egen numpersys_`var'=sum(unqpersys_`var')
		}

		foreach var in system_nam owner_type d_prin_cit d_prin_cnt d_fed_prim d_populati d_ttl_stor d_pws_fed_ water_type {
			tab numpersys_`var'
		}

		* Creating a variable with total number of sw and gu facilities per water system
		bysort number0: gen num_sw_gu_facilities=_N
		bysort number0: egen num_sw_facilities=sum((water_type=="SW"))
		bysort number0: egen num_gu_facilities=sum((water_type=="GU"))	
		gen has_sw_facilities_ind=1 if num_sw_facilities>=1 &  num_sw_facilities<.
		replace has_sw_facilities_ind=0 if num_sw_facilities==0 
		gen has_gu_facilities_ind=1 if num_gu_facilities>=1 &  num_sw_facilities<.
		replace has_gu_facilities_ind=0 if num_gu_facilities==0 
		keep if unique_pws==1
		keep has_nmdwb_data number0 system_nam owner_type d_prin_cit d_prin_cnt d_fed_prim d_populati d_ttl_stor d_pws_fed_ num_sw_gu_facilities num_sw_facilities num_gu_facilities has_sw_facilities_ind has_gu_facilities_ind
		sort number0
		save data/systems_surface.dta, replace

	*Aggregating active ground water systems information to have one entry per surface water system
		use rawdata/active_ground_water_systems.dta, clear
		gen has_nmdwb_data="Yes"
		* Creating an indicator to select only one observation per system
		bysort number0: gen unique_pws=_n==1

		* Checking number of values per system for system variables. 
		* All should have numpersys_`var' be equal to 1 except for water_type that can be 2 if the water system has GU and SW
		foreach var in system_nam owner_type d_prin_cit d_prin_cnt d_fed_prim d_populati d_ttl_stor d_pws_fed_ water_type {
			bysort number0 `var': gen unqpersys_`var'=_n==1
			bysort number0: egen numpersys_`var'=sum(unqpersys_`var')
		}	

		foreach var in system_nam owner_type d_prin_cit d_prin_cnt d_fed_prim d_populati d_ttl_stor d_pws_fed_ water_type {
			tab numpersys_`var'
		}

		* Creating a variable with total number of sw and gu facilities per water system
		bysort number0: gen num_gw_facilities_test=_N
		bysort number0: egen num_gw_facilities=sum((water_type=="GW"))

		gen has_gw_facilities_ind=1 if num_gw_facilities>=1 &  num_gw_facilities<.
		replace has_gw_facilities_ind=0 if num_gw_facilities==0 
		keep if unique_pws==1
		keep has_nmdwb_data number0 system_nam owner_type d_prin_cit d_prin_cnt d_fed_prim d_populati d_ttl_stor d_pws_fed_ num_gw_facilities has_gw_facilities_ind
		sort number0
		save data/systems_ground.dta, replace

	* Creating a unique file with both ground water and surface water systems
		use data/systems_ground.dta, clear
		merge 1:1 number0 using data/systems_surface.dta
	
		* Replace variables with 0 if they don't appear in both a surface and ground water file	
		replace num_gw_facilities=0 if _merge==2 & num_gw_facilities==.
		replace has_gw_facilities=0 if _merge==2 & has_gw_facilities==.
		replace num_sw_gu_facilities=0 if _merge==1 & num_sw_gu_facilities==.
		replace num_sw_facilities=0 if _merge==1 & num_sw_facilities==.
		replace num_gu_facilities=0 if _merge==1 & num_gu_facilities==.
		replace has_sw_facilities_ind=0 if _merge==1 & has_sw_facilities==.
		replace has_gu_facilities_ind=0 if _merge==1 & has_gu_facilities==.
	
		gen surface_ground_facility_type="Surface" if (has_sw_facilities_ind==1 | has_gu_facilities_ind==1) & has_gw_facilities_ind==0
		replace surface_ground_facility_type="Ground" if has_sw_facilities_ind==0 & has_gu_facilities_ind==0 & has_gw_facilities_ind==1
		replace surface_ground_facility_type="Surface and Ground" if (has_sw_facilities_ind==1 | has_gu_facilities_ind==1) & has_gw_facilities_ind==1
		drop _merge
		save data/pws.dta, replace	

*** Merging water source ratio information for PWS with principal water source equal to SW and GU
		
	* Joining with additional variables
	use data/pws.dta, clear
	merge 1:1 number0 using data/source_ratio_surface_pws.dta
	replace surface_pws=0 if surface_pws==.
	gen has_source_ratio_surface_pws=(_merge!=2)
	replace has_nmdwb_data="No" if _merge==2 & has_nmdwb_data==""
	drop _merge
	save data/pws.dta, replace
	
*** Joining the MHI income and Disadvantaged Status Type to the PWS database
	
	* Joining the MHI variables to the PWS database
	use "rawdata/PWS_with_2010_MHI.dta", clear
	bysort system_nam: gen num_obs=_N
	tab system_nam mhi_2010 if num_obs!=1
	duplicates drop
	drop num_obs
	destring mhi_2010, replace
	sort system_nam
	save data/pws_2010_mhi.dta, replace

	use data/pws.dta, clear
	merge 1:1 number0 using "data/pws_2010_mhi.dta"	
	gen has_mhi_data="Yes" if _merge==3 | _merge==2
	replace has_mhi_data="No" if _merge==1 

	gen has_drinking_water_data="Yes" if _merge==3 | _merge==1
	replace has_drinking_water_data="No" if _merge==2 
	replace has_nmdwb_data="No" if _merge==2 & has_nmdwb_data==""
	drop _merge
	gen ratio_pws_mhi_over_state_mhi=mhi_2010/48059

	browse if has_mhi_data=="No" & (number0 =="NM3501024" | number0== "NM3501024"	| number0== "NM3533223"	| number0== "NM3502221"	| number0== "NM3513319"	| number0== "NM3510701"	| number0== "NM3509824"	| number0== "NM3573725"	| number0== "NM3510124"	| number0== "NM3502826"	| number0== "NM3501021"	| number0== "NM3526204"	| number0== "NM3526704"	| number0== "NM3510224"	| number0== "NM3509223"	| number0== "NM3513719"	| number0== "NM3518025"	| number0== "NM3500624"	| number0== "NM3510324"	| number0== "NM3502721"	| number0== "NM3526504"	| number0== "NM3536724"	| number0== "NM3520024"	| number0== "NM3530504"	| number0== "NM3513114"	| number0== "NM3505126"	| number0== "NM3526604"	| number0== "NM3546419"	| number0== "NM3514019"	| number0== "NM3503521" )

	* Compute the system's disadvantage status
	gen disadvantage_status_type="Severely Disadvantaged" if ratio_pws_mhi_over_state_mhi<=.8
	replace disadvantage_status_type="Disadvantaged" if ratio_pws_mhi_over_state_mhi<=1 & 	ratio_pws_mhi_over_state_mhi>.8
	replace disadvantage_status_type="Non-Disadvantaged" if ratio_pws_mhi_over_state_mhi>1 & 	ratio_pws_mhi_over_state_mhi<.
	sort system_nam

	*browse if has_mhi_data=="No" & (number0 =="NM3501024" | number0== "NM3501024"	| number0== "NM3533223"	| number0== "NM3502221"	| number0== "NM3513319"	| number0== "NM3510701"	| number0== "NM3509824"	| number0== "NM3573725"	| number0== "NM3510124"	| number0== "NM3502826"	| number0== "NM3501021"	| number0== "NM3526204"	| number0== "NM3526704"	| number0== "NM3510224"	| number0== "NM3509223"	| number0== "NM3513719"	| number0== "NM3518025"	| number0== "NM3500624"	| number0== "NM3510324"	| number0== "NM3502721"	| number0== "NM3526504"	| number0== "NM3536724"	| number0== "NM3520024"	| number0== "NM3530504"	| number0== "NM3513114"	| number0== "NM3505126"	| number0== "NM3526604"	| number0== "NM3546419"	| number0== "NM3514019"	| number0== "NM3503521" )
	*browse number0 system_nam mhi ratio_pws disadvanta if has_mhi_data=="Yes" & (number0 =="NM3501024" | number0== "NM3501024"	| number0== "NM3533223"	| number0== "NM3502221"	| number0== "NM3513319"	| number0== "NM3510701"	| number0== "NM3509824"	| number0== "NM3573725"	| number0== "NM3510124"	| number0== "NM3502826"	| number0== "NM3501021"	| number0== "NM3526204"	| number0== "NM3526704"	| number0== "NM3510224"	| number0== "NM3509223"	| number0== "NM3513719"	| number0== "NM3518025"	| number0== "NM3500624"	| number0== "NM3510324"	| number0== "NM3502721"	| number0== "NM3526504"	| number0== "NM3536724"	| number0== "NM3520024"	| number0== "NM3530504"	| number0== "NM3513114"	| number0== "NM3505126"	| number0== "NM3526604"	| number0== "NM3546419"	| number0== "NM3514019"	| number0== "NM3503521" )
	*browse number0 system_nam has_mhi_data has_drinking_water_data mhi ratio_pws disadvanta if number0== "NM3590024"	| number0== "NM3592729"	| number0== "NM3590619"	| number0== "NM3593225"	| number0== "NM3593621"	| number0== "NM3567424"	| number0== "NM3593221"	| number0== "NM3590924"	| number0== "NM3593821"	| number0== "NM3595017"

	save data/pws.dta, replace	
	

*** Aggregate intakes information to have one entry per surface water system
	use "rawdata/active_surface_water_intakes_impact_20201116.dta", clear

	* Creating an indicator to select only one observation per system
	bysort number0: gen unique_pws=_n==1
	* Aggregate total number of intakes	per water system
	bysort number0: gen  total_intakes=_N
	bysort number0: egen sw_intakes=sum((water_type=="SW"))
	bysort number0: egen gw_intakes=sum((water_type=="GW"))
	bysort number0: egen gu_intakes=sum((water_type=="GU"))
	gen total_gu_sw_intakes=sw_intakes+gu_intakes
	gen alternative_intakes=1 if (total_intakes>total_gu_sw_intakes)
	replace alternative_intakes=0 if (total_intakes==total_gu_sw_intakes)
	
	* Aggregate number of impacted intakes
	bysort number0: egen impacted_sw_intakes=sum((water_type=="SW")*impact)
	bysort number0: egen impacted_gu_intakes=sum((water_type=="GU")*impact)
	bysort number0: egen impacted_gu_sw_water_intakes=sum((water_type=="GU"| water_type=="SW")*impact)

	
	* Ratio of impacted intakes to total number of intakes
	gen ratio_impacted_gu_sw_over_all=impacted_gu_sw_water/total_intakes
	gen ratio_gu_sw_impacted_over_gu_sw=impacted_gu_sw_water_intakes/total_gu_sw_intakes
	
	* Is PWS impacted
	gen pws_impacted="Yes" if impacted_gu_sw_water_intakes>0 & impacted_gu_sw_water_intakes<.
	replace pws_impacted="No" if impacted_gu_sw_water_intakes==0
	rename system_nam test_system_name
	keep if unique_pws==1
	keep number0 total_intakes sw_intakes gw_intakes gu_intakes total_gu_sw_intakes impacted_sw_intakes impacted_gu_intakes impacted_gu_sw_water_intakes ratio_impacted_gu_sw_over_all ratio_gu_sw_impacted_over_gu_sw alternative_intakes
	sort number0
	save data/impact_intakes.dta, replace
	
*** Merging the information on intakes impact to the PWS database
	use data/pws.dta, clear
	merge 1:1 number0 using data/impact_intakes.dta	
	gen has_surface_intake_geo_info=1 if _merge==3 | _merge==2
	replace has_surface_intake_geo_info=0 if _merge==1
	tab  has_surface_intake_geo_info
	drop _merge
	save data/pws.dta,replace
	
	
*** Merging surface purchaser data
	use data/pws.dta, clear
	merge 1:1 number0 using data/surface_purchaser_info_surface_pws.dta
	gen has_surfacepurchase_data="Yes" if _merge==3
	replace has_surfacepurchase_data="No" if _merge==1
	drop _merge
	save data/pws.dta,replace

	
	
	


	
	
