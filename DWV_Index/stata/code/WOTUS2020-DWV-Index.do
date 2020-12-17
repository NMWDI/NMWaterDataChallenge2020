cd "/Users/tamali/NMStory/stata/"
	
* Keep PWS with active water systems data (Source: New Mexcio Drinkin Water Bureau)
	use data/pws.dta,clear
	keep if has_nmdwb_data=="Yes"
	
*** Compute the PWS's WOTUS water index
	gen wotus2020_dwv_index=.

	* If the PWS is a GW PWS then we assume that they don't have any surface water intakes and hence the vulnerability impact is 1 
	replace wotus2020_dwv_index=1 if surface_pws==0
	
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
	
	drop surf_wtr_ratio surf_wtr_pur_ratio grnd_wtr_udi_ratio grnd_wtr_udi_purch surface_ratio_if_spws
	export delimited if has_surface_intake_geo_info==1 using data/wotus2020-DWV-Index_surface_pws.csv, replace
	export delimited using data/wotus2020-DWV-Index_all_pws.csv, replace
