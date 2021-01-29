	
* Keep PWS with active water systems data (Source: New Mexico Drinking Water Bureau)
	use data/pws.dta,clear
	keep if has_nmdwb_data=="Yes"
	
*** Compute the PWS's WOTUS water index
	gen wotus2020_dwv_index=.

	* If the PWS is a GW PWS then we assume that they don't have any surface water intakes and hence the vulnerability impact is 1 
	replace wotus2020_dwv_index=1 if d_fed_prim=="GW" | d_fed_prim=="GWP"
	
	* Any SW or GU Water intake impacted?
	replace wotus2020_dwv_index=1 if ratio_impacted_gu_sw_over_all==0

	* At least one SW or GU Water intake impacted with alternative water types
	replace wotus2020_dwv_index=2 if ratio_impacted_gu_sw_over_all>0 & total_intakes>total_gu_sw_intakes & disadvantage_status_type=="Non-Disadvantaged" & ratio_impacted_gu_sw_over_all<=1
	replace wotus2020_dwv_index=3 if ratio_impacted_gu_sw_over_all>0 & total_intakes>total_gu_sw_intakes & disadvantage_status_type=="Disadvantaged" & ratio_impacted_gu_sw_over_all<=1
	replace wotus2020_dwv_index=3 if ratio_impacted_gu_sw_over_all>0 & total_intakes>total_gu_sw_intakes & disadvantage_status_type=="" & ratio_impacted_gu_sw_over_all<=1
	replace wotus2020_dwv_index=4 if ratio_impacted_gu_sw_over_all>0 & total_intakes>total_gu_sw_intakes & disadvantage_status_type=="Severely Disadvantaged" & ratio_impacted_gu_sw_over_all<=1

	* Subset of SW and GU water intakes impacted with no alternative water types
	replace wotus2020_dwv_index=5 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Non-Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw<1
	replace wotus2020_dwv_index=6 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw<1
	replace wotus2020_dwv_index=6 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="" & ratio_gu_sw_impacted_over_gu_sw<1
	replace wotus2020_dwv_index=7 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Severely Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw<1

	* All SW and GU water intakes impacted with no alternative water types
	replace wotus2020_dwv_index=8 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Non-Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw==1
	replace wotus2020_dwv_index=9 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw==1
	replace wotus2020_dwv_index=9 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="" & ratio_gu_sw_impacted_over_gu_sw==1
	replace wotus2020_dwv_index=10 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Severely Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw==1

	browse if has_surface_intake_geo_info==1
	
	* For SWP their 
	preserve
	drop if d_fed_prim=="SWP"
	keep number0 system_nam wotus2020_dwv_index
	rename system_nam seller_system_name_1
	rename number0 seller_number0_1
	rename wotus2020_dwv_index seller_wotus2020_dwv_index_1
	save prov/prov.dta,replace
	restore
	
	* substitute into the SWP the DWV index of their seller
	merge m:1 seller_number0_1 using  prov/prov.dta
	drop if _merge==2
	replace wotus2020_dwv_index=seller_wotus2020_dwv_index_1 if _merge==3 & d_fed_prim=="SWP"
	drop _merge
	preserve
	use prov/prov.dta,clear
	rename seller_system_name_1 seller_system_name_2
	rename seller_number0_1 seller_number0_2
	rename seller_wotus2020_dwv_index_1 seller_wotus2020_dwv_index_2
	save prov/prov.dta,replace
	restore
	
	* substitute into the SWP with two surface water sellers the minimum value DWV index of the sellers
	merge m:1 seller_number0_2 using  prov/prov.dta
	drop if _merge==2
	
	replace wotus2020_dwv_index=min(seller_wotus2020_dwv_index_1,seller_wotus2020_dwv_index_2) if _merge==3 & d_fed_prim=="SWP"
	browse if _merge==3
	drop _merge

	* Summary of index impact
	gen index_summary="No Direct Impact" if wotus2020_dwv_index==1
	replace index_summary="Direct Impact Non-Community Water System" if index_summary=="" &  wotus2020_dwv_index<. & d_pws_fed_!="C"
	replace index_summary="Direct Impact with Alternative Sources of Water" if wotus2020_dwv_index>=2 & wotus2020_dwv_index<=4 &  index_summary=="" & d_pws_fed_=="C"
	replace index_summary="Direct Impact with No Alternative Sources of Water" if wotus2020_dwv_index>=5 & wotus2020_dwv_index<=10 &  index_summary=="" & d_pws_fed_=="C"


	
	save data/wotus2020-DWV-Index_surface_pws.dta,replace
	
	*drop surf_wtr_ratio surf_wtr_pur_ratio grnd_wtr_udi_ratio grnd_wtr_udi_purch surface_ratio_if_spws
	export delimited if has_surface_intake_geo_info==1 using data/wotus2020-DWV-Index_surface_pws.csv, replace
	export delimited using data/wotus2020-DWV-Index_all_pws.csv, replace
	
	gen primary_county=d_prin_cnt+" COUNTY"
	gen primary_water_source="Ground Water" if d_fed_prim=="GW"
	replace primary_water_source="Surface Water-Purchase" if d_fed_prim=="SWP"
	replace primary_water_source="Surface Water" if d_fed_prim=="SW"
	replace primary_water_source="Ground Water-Purchase" if d_fed_prim=="GWP"
	replace primary_water_source="Ground Water Under the Direct Influence of Surface Water" if d_fed_prim=="GU"

	label var system_nam "Water System Name"
	label var wotus2020_dwv_index "Index"
    label var d_prin_cit "Primary City"
	label var primary_county "Primary County"
	label var d_populati "Pop. Served"
	label var gw_intakes "Ground Water Intakes"
	label var total_intakes "Total Number of Intakes"
	label var disadvantage_status_type "Disadvantaged Community Status"
	label var index_summary "Index Summary"
	label var primary_water_source "Primary Water Source"

	export excel system_nam wotus2020_dwv_index index_summary disadvantage_status d_prin_cit primary_county d_pop gw_intakes total_intakes primary_water_source using data/wotus2020-Table.xlsx, sheet(WOTUS2020-Table) sheetreplace firstrow(varlabels)

