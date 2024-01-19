import pandas as pd
import numpy as np 
import plotly.express as px
import matplotlib.pyplot as plt

#importing dataset
#2019 US census states population statistics
states_data = pd.read_csv('states_data_2019_new.csv')

#goal:
#Visualize population statistics from 2019 using plotly choropleth to visually compare states

#categories
for col in states_data.columns:
    print(col)

#function to create visualization
def visualization(dataset, variables=[]):

    for i, var in enumerate(variables):
        fig = px.choropleth(
            dataset,
            locations = "states_code",
            locationmode='USA-states',
            scope = 'usa',
            hover_name= "state_name",
            title = f"{var} in 2019",
            color = var,
            color_continuous_scale= 'geyser',
            range_color = (min(dataset[var]), max(dataset[var])),
        )  
        fig.show()

#population
viz_pop = visualization(states_data, ["pop_2019", "population_density"])
#It is evident that California had the highest population in 2019, then Texas, and then Florida and New York.
#New York and Virginia had the highest population densities


#births
viz_births = visualization(states_data, ["births_2019", "birth_rate"])
#It appears that the highly populated regions had the most births as expected.
#States in the midwest (Utah, Nebraska, South Dakota, North Dakota) had the highest birth rates. 
#Higher birth rate likely indicates a higher proportion of younger individuals. 


#deaths
viz_deaths = visualization(states_data, ["deaths_2019", "death_rate"])
#As expected, the most highly populated regions also had the highest amount of deaths. 
#Death rate was higher in states in the east side of the US, with West Virginia having the highest death rate.
#Higher death rate likely indicates a higher proportion of an older population. 


#international migration
viz_int_migr = visualization(states_data, ["international_migration", "international_migration_rate"])
#Florida had the highest international migration, with California, Texas, and New York being the next highest. 
# Florida also had the highest international migration rate unsurprisingly. 
#However, Washington, Connecticut, Massachusetts, and Rhode Island had the next highest international migration rates while not having as high total international migrants. 


#domestic migration
viz_dom_migr = visualization(states_data, ["domestic_migration", "domestic_migration_rate"])
#California and New York, and Illinois appear to have had the lowest domestic migration in 2019, with a net decrease. 
#Florida and Texas had the highest domestic migration. 
#Idaho, Nevada, and Arizona had the highest domestic migration rates. 


#growth rate between 2018 to 2019
viz_growth_rate = visualization(states_data, ["one_year_growth_rate"])
#Growth rate encompasses births, deaths, international migration, domestic migration, and a residual factor. 
#Texas had the highest growth rate, with Georgia being the next highest.
#Illinois had the lowest growth rate. 