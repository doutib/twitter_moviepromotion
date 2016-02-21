import csv
import pandas as pd
da = pd.read_csv('movies.csv')
screen_names = da['handle_name']
df = da.rename(index=da['handle_name'])
df.loc['starwars']['2015 Gross']