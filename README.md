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
