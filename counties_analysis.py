import pandas as pd 
import matplotlib.pyplot as plt
import seaborn as sns 
import plotly.express as px
import json


#load states data
county_data = pd.read_csv("counties_data_2010_2019.csv")
county_data.head()

#get county boundary coordinates which is needed for map visualization:
with urlopen('https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json') as response:
    counties = json.load(response)

# Adding a 0 to the beginning of fips with only 4 characters
new_fips = []
for fip in county_data["fips"]:
    if len(str(fip)) == 4:
        new = str(0) + str(fip) 
        new_fips.append(new)
    else:
        new_fips.append(fip)

county_data["fips"] = new_fips

county_data.describe()


#CORRELATIONS BETWEEN VARIABLES
#Using variables relating to 2010 data (2010 population stats, land area)
#Main purpose is to see if there is a correlation between those variables and percent growth or raw change
var_for_matrix = county_data[['pop_2010', 'land_area', 'population_density_2010', 'percent_growth', 'raw_change']]

#correlation matrix
correlation_matrix = var_for_matrix.corr(method = 'pearson')

#heatmap
plt.figure(figsize=(10,8))
a = sns.heatmap(correlation_matrix, cmap = "crest",annot= True)
a.set_title("Correlation Heatmap", fontsize=16)

plt.show()

#Findings
#it is evident that raw change and percent growth are highly correlated, at around 0.8. 
# This is surprising since at the county-level analysis, there was not a high correlation between the two. 

#Similarly to the county data analysis, 2010 population and raw change had a high correlation (0.72).


#VISUALIZATIONS ON A MAP
#raw change and percent growth of population betwween 2010 and 2019 visualized using plotly express

vars_visual = ["raw_change", "percent_growth"]

for var in vars_visual:
    fig = px.choropleth(county_data,
                        geojson= counties, 
                        locations = "fips",
                        scope="usa",
                        color = var, 
                        color_continuous_scale="icefire",
                        range_color= (min(county_data[var]), max(county_data[var])),
                        hover_data = ["county_name","state_name"],
                        title=(f"{var.title()} of Population in Each County From 2010-2019"))
    fig.show()

#Findings
#Raw Change
#From the visualization, it shows that there were many counties in California, Texas, Florida, and a couple in Washington which experienced a higher increase in population.

#Percent Growth
#From the percent population growth map, it shows that Williams County and McKenzie County in North Dakota had very high percent growth from 2010-2019. 
#Loving County in Texas also had an extremely high percent growth.

#Generally, it appeared that counties in the west coast and east coast saw more growth than counties in the mid region of the US (except Texas).