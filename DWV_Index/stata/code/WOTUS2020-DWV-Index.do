*clear all
*import delimited "/Users/tamali/NMStory/WOTUS2020_DWV_Index_data.csv", clear
	
* Keep PWS with complete information
	use data/pws.dta,clear
	* Keep surface water systems (Primary water source SW or GU)
	keep if surface_pws==1


*** Compute the PWS's WOTUS water index
	gen wotus2020_dwv_index=.

	* Any SW or GU Water intake impacted?
	replace wotus2020_dwv_index=1 if ratio_impacted_gu_sw_over_all==0

	* At least one SW or GU Water intake impacted with alternative water types
	replace wotus2020_dwv_index=2 if ratio_impacted_gu_sw_over_all>0 & total_intakes>total_gu_sw_intakes & disadvantage_status_type=="Non-Disadvantaged"
	replace wotus2020_dwv_index=3 if ratio_impacted_gu_sw_over_all>0 & total_intakes>total_gu_sw_intakes & disadvantage_status_type=="Disadvantaged"
	replace wotus2020_dwv_index=4 if ratio_impacted_gu_sw_over_all>0 & total_intakes>total_gu_sw_intakes & disadvantage_status_type=="Severely Disadvantaged"

	* Subset of SW and GU water intakes impacted with no alternative water types
	replace wotus2020_dwv_index=5 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Non-Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw<1
	replace wotus2020_dwv_index=6 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw<1
	replace wotus2020_dwv_index=7 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Severely Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw<1

	* All SW and GU water intakes impacted with no alternative water types
	replace wotus2020_dwv_index=8 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Non-Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw==1
	replace wotus2020_dwv_index=9 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw==1
	replace wotus2020_dwv_index=10 if ratio_impacted_gu_sw_over_all>0 & total_intakes==total_gu_sw_intakes & disadvantage_status_type=="Severely Disadvantaged" & ratio_gu_sw_impacted_over_gu_sw==1

	browse if has_surface_intake_geo_info==1

	export delimited if has_surface_intake_geo_info==1 using data/wotus2020-DWV-Index_surface_pws.csv, replace
