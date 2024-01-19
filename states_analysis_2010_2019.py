import pandas as pd 
import matplotlib.pyplot as plt
import seaborn as sns 
import plotly.express as px

#load states data
states_data = pd.read_csv("states_data_2010_2019.csv")
states_data.head()

#insert states codes into table
states_codes=["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC","FL", "GA", 
            "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", 
            "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", 
            "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]

#sort data frame to be alphabetical
states_data = states_data.sort_values("state_name")
states_data.isna().sum()

#replace state fips with state codes - need state codes to visualize data in choropleth map
states_data["state_fips"] = states_codes
states_data.rename(columns={"state_fips": "state_code"}, inplace = True)

 #summary stats
states_data.describe()


#CORRELATIONS BETWEEN VARIABLES
#Using variables relating to 2010 data (2010 population stats, land area)
#Main purpose is to see if there is a correlation between those variables and percent growth or raw change
var_for_matrix = states_data[['pop_2010', 'land_area', 'population_density_2010', 'percent_growth', 'raw_change']]

#correlation matrix
correlation_matrix = var_for_matrix.corr(method = 'pearson')

#heatmap
plt.figure(figsize=(10,8))
a = sns.heatmap(correlation_matrix, cmap = "crest",annot= True)
a.set_title("Correlation Heatmap", fontsize=16)

plt.show()

#Findings
#It is interesting to see that raw change in population and percent growth in population have a high correlation, at around 0.8.
#This is interesting because it was not seen when looking at these changes at a county level.
#There is also a high correlation (0.72) between raw change in population and the 2010 population, this is expected since regions with higher populations tend to see more raw growth.
#This correlation was also seen at the county level.



#VISUALIZATIONS ON A MAP
#raw change and percent growth of population betwween 2010 and 2019 visualized using plotly express

vars_visual = ["raw_change", "percent_growth"]

for var in vars_visual:
    fig = px.choropleth(states_data,
                        locations = "state_code", 
                        locationmode="USA-states",
                        scope="usa",
                        color = var, 
                        color_continuous_scale="icefire",
                        color_continuous_midpoint=0,
                        hover_name = "state_name",
                        title=(f"{var.title()} of Population in Each State From 2010-2019"))
    fig.show()

#Findings
#Raw Change
# Texas clearly had the highest raw change in population form 2010 to 2019, with Florida and California being the next most.
# States in the middle region of the US (except Texas) appear to have not as high of a raw increase as the West or East coast.

#Growth Percentage
# Texas has the highest growth percentage, with Florida being next. 
# Some states in the middle of the US had a negative percentage growth
# # Kansas and Illinois both had the most negative growth percentages.