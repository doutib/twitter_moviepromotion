import json
import csv
import pandas as pd
from re import sub
import matplotlib.pyplot as plt
import numpy as np

with open("Release_timelines.json") as infile:
    timelines = json.load(infile)

with open("movies-list.json") as infile:
    movies = json.load(infile)

da = pd.read_csv('Movies.csv')
df = da.rename(index=da['handle_name'])
screen_names = df['handle_name']

# timelines are dictonary with 89 movie names as key and their corresponding timelines as value

#discover the relationship of the number of tweets and the movie sales
time_num = [len(timelines[movie]) for movie in screen_names]
sales = [df.loc[movie]['2015 Gross'] for movie in screen_names]
values = [int(sub(r'[^\d.]', '', money)) for money in sales]
m,b = np.polyfit(time_num,values,1)
y = [m*x+b for x in time_num]

plt.plot(time_num, values,'o')
plt.xlabel("number of tweets")
plt.ylabel("box office sales")
plt.title("relationship between the activity of the movie on Twitter and its box office sales") 
plt.plot(time_num, y,'-')
plt.savefig("tweets_sales")
plt.show()


#discover the relathionship of the number of followers and the movie sales
#e.g. movies['users'][0]['followers_count'] ## the followers data for 'the big short movie' which is at index 0

name_order = [movies['users'][i]['screen_name'] for i in range(len(movies['users']))]
followers = [movies['users'][i]['followers_count'] for i in range(len(movies['users']))]
sales_order = [df.loc[movie]['2015 Gross'] for movie in name_order]
values_order = [int(sub(r'[^\d.]', '', money)) for money in sales_order]
beta,a = np.polyfit(followers,values_order,1)
y_order = [beta*x+a for x in followers]

plt.plot(followers, values_order,'o')
plt.xlabel("number of followers")
plt.ylabel("box office sales")
plt.title("relationship between the popularity of the movie on Twitter and its box office sales") 
plt.plot(followers, y_order,'-')
plt.savefig("followers_sales")
plt.show()






