# New Mexico Water Data Challenge 2020

## Overview
In its present iteration, the dashboard visualizes the impacts to waterways, communities, and water systems that are adversely affected by changes to the Clean Water Act. These changes reduce the amount of protection afforded to waterbodies known as Water of the United States. To quantify its impact, we considered hydrological, socio-economic, demographic, as well as utilities information that are publicly available.    
  
The dashboard is currently hosted [here](http://shiny.newmexicowaterdata.org/) at a server owned by the [New Mexico Water Data Initiative](https://catalog.newmexicowaterdata.org/).      
  
### Navigating the Dashboard  
The dashboard is made up of two sections: Statewide and County.  
    
The Statewide section provides a broad summary of the present situation in New Mexico. All indicators and statistics provided in this section are all summarized to the state level.  
  
The County section, as its name suggests, agglomerates statistics at the level of each county in New Mexico. Users will have to select the county they wish to explore and visualize through a drop-down menu on the panel on the left.  
  
## The Numbers  
In this section of the README, we will provide a broad summary of the steps we took to obtain the numbers you see in the panels and the maps.  
  
### Human Development Index (HDI)  
The HDI is a statistic used by the United Nations to rank and measure each country's socio-economic development in terms of educational outcomes, income, and life expectancy. This is globally benchmarked and measured at the scale of countries. However, what we want to do here is to adapt it to New Mexico and to measure how each county stacks up in comparison to others. More fundamentally, it acknowledges the fact that not all counties are the same when it comes to socio-economic development. What we want to know is how different they are and gauge how likely they are to be affected by these legislative changes.  
  
All estimations were first performed at the census tract before agglomerating to the county level. This is to account for potential huge variations in-county. For example, the inner city of Albuquerque in Bernalillo County probably looks very different from its suburbs. I estimated life expectancy by using the National Center for Health Statistics' US Small-area Life Expectancy Estimates Project results. Income and educational attainment were estimated using the 2018 American Community Survey as the 2019 American Community Survey and 2020 Decennial Census results were unavailable at the census tract level at the time of data processing.  

As mentioned, the Human Development Index comprises of three dimensions: life expectancy, income, and educational attainment in terms of mean years of education.  

The dimension value for each metric is calculated as:  
  
<img src="https://render.githubusercontent.com/render/math?math=Dimension = \frac{actual-minimum}{maximum-minimum}">  
  
Ad adjustment will have to be made for the income dimension as documented in the [HDI Training Report](http://hdr.undp.org/sites/default/files/hdi_training.pdf) produced by the UN Development Program. Natural logarithm (ln) has to be taken for all entries.  
  
<img src="https://render.githubusercontent.com/render/math?math=Income Dimension = \frac{ln(actual)-ln(minimum)}{ln(maximum)-ln(minimum)}">  

In order to aggregate the three dimensions to form the HDI:  
  
<img src="https://render.githubusercontent.com/render/math?math=HDI = (I^{income}*I^{education}*I^{life exp.})^{1/3}">  
  
### Unprotected Waterbodies, Pollutants, and Water Intakes  
In order to map these data points out on a Leaflet engine, geospatial data in the form of shapefiles had to be obtained from the New Mexico Water Data Initiative's [data catalog](https://catalog.newmexicowaterdata.org/). They were then processed and reduced in size to facilitate web-mapping.  
  
The dataset that had to be reduced in size most drastically was that of the waterbodies in New Mexico. Due to the geomorphology and climate of New Mexico, there are a lot of ephemeral and intermittent streams that are prone to disconnection from perennial streams due periods of low precipitation. Under the new Clean Water Act rules, these would be excluded from protection.  
  
To quantify the impact, the stream lengths of these unprotected streams were tabulated at the scale of each county by clipping a shapefile of NM's counties over the [New Mexico NHD High Resolution Stream segments and Waterbodies](https://catalog.newmexicowaterdata.org/dataset/nm-nhs-stream) dataset. However, given the sheer number of waterbodies, it is impossible to plot all of them onto the dashboard. Thus, only those that are classed as "Disconnected" are shown, even though Ephemeral and Disconnected waterbodies will not be protected under the new rules. Furthermore, the polylines of the streams were simplified geometrically to further reduce file size and enhance performance. A secondary consideration was to avoid pinpointing streams that are now unprotected from users who might take advantage of the lack of legal protection.  
  
### Drinking Water Vulnerability Index  
The WOTUS 2020 Drinking Water Vulnerability Index index measures the risk to a Community Water System (CWS)’s population’s drinking water due to ephemeral and disconnected streams’ loss of protection due to the change in WOTUS definition.  
  
The index is an ordinal measure of the risk to the CWS that takes 10 values, 1-10. Note that the fact that it is an ordinal index means that increasing by one the index does not necessarily have the same impact at different levels of the index, i.e. the danger posed to a CWS’s water intakes by moving from 2 to 3 does not imply the same increase in risk to drinking water sources when moving from 9 to 10. This index can be refined to have more levels of impact, one of the most relevant variables to incorporate to the index is the size of the CWS (population served). This parameter influences considerably the resources, economic and technical, available to the water system to circumvent a contamination event to their water sources.  
  
The risk to a CWS is based on three areas: the loss of protection of streams very near the CWS’s water intake, the intensity of the impact to the CWS water intakes and the financial vulnerability of the communities’ served by the water system (i.e. a community’s affordability to finance a potential contamination incident).  
  
We consider a CWS is impacted if any of their surface water intakes (SW) or ground water intakes under direct influence of surface water (GU) are within a .5 mile from an Ephemeral or Disconnected stream. Potential contamination to one of the intakes will impact all the water stored in the CWS.  
  
The intensity of the impact to drinking water source takes into account the percentage of the surface water intakes that are impacted and the CWS’s access to alternative water supplies.  
  
Finally, not all CWS have the same resources to fund any potential damages to their water sources as a product of the WOTUS definition change. In order to identify a community’s ability to pay for these damages, we use the affordability criteria used by the New Mexico Finance Authority (NMFA) when extending programs to assist disadvantaged communities. 
