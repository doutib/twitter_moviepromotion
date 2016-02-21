import twitter
import json
from time import sleep
import string
import re
from collections import Counter

CONSUMER_KEY = 'ooxT4Fs9IYYEQdIZ0fbDjFENO'
CONSUMER_SECRET = '67GtEDhlgNCFMee55WZrVmDPY8znqULAkGKuB6SafPS08Nu7y0'
OAUTH_TOKEN = '4789861620-gy3ywaHhJVWjCfP0668bAipIULfYEkY9x40rCAS'
OAUTH_TOKEN_SECRET = '35bfXGrI4FqEN4Q8S3EHJIG9pv5DOUzP4YsfTXfO4118o'

auth = twitter.oauth.OAuth(OAUTH_TOKEN, OAUTH_TOKEN_SECRET,
                           CONSUMER_KEY, CONSUMER_SECRET)
api = twitter.Twitter(auth=auth)

# get the list of movies
movies = api.lists.members(owner_screen_name="YaoZenjo", 
                             slug="TOP100Movies2015",
                             count=100)

with open("movies-list.json", "w") as f:
    json.dump(movies, f, indent=4, sort_keys=True)

names = [d["screen_name"] for d in movies["users"]]

def retrieve_timeline(screen_name):
    
    print("Beginning retrieval of", screen_name, "...")
    try:
        timeline = api.statuses.user_timeline(screen_name=screen_name,
                                              count=200, include_rts=1)
    except:
        print("Reached rate limit; sleeping 15 minutes")
        sleep(900)
        timeline = api.statuses.user_timeline(screen_name=screen_name,
                                              count=200, include_rts=1)

    ntweets = len(timeline)
    if ntweets < 100:
        timeline += next_timeline
        print("Stop retrieval of", screen_name, "with sample size", len(timeline))
        return timeline
    while ntweets >= 100 and len(timeline) < 800:
        min_id = min([tweet["id"] for tweet in timeline])
        try:
            next_timeline = api.statuses.user_timeline(screen_name=screen_name,
                                                       count=200,
                                                       max_id=min_id - 1,
                                                       include_rts=1)
        except:
            print("Reached rate limit; sleeping 15 minutes")
            sleep(900)
            next_timeline = api.statuses.user_timeline(screen_name=screen_name,
                                                       count=200,
                                                       max_id=min_id - 1,
                                                       include_rts=1)
        ntweets = len(next_timeline)
        timeline += next_timeline
    print("Stop retrieval of", screen_name, "with sample size", len(timeline))
    return timeline

timelines = [retrieve_timeline(screen_name=name) for name in names]

# Stroe timelines and names information
with open("Movie_timelines.json", "w") as f:
    json.dump(timelines, f, indent=4, sort_keys=True)
    
with open("Movie_names.json", "w") as f:
    json.dump(names, f, indent=4, sort_keys=True)

# Read timelines and names information
with open("Movie_timelines.json") as infile:
    timelines = json.load(infile)
    
with open("Movie_names.json") as infile:
    names = json.load(infile)

timelines[0][0]['text']

def clean(tweet):
    cleaned_words = [word.lower() for word in tweet.split() if '#' not in word and
                     '@' not in word and 'http' not in word and word != 'RT']
    return ' '.join(cleaned_words)

def rm_pun(word):
    if word[-1] in string.punctuation:
        return word[:-1]
    else:
        return word

tweet = "RT OH, GOOD weaTher. Isn't it? https://t.co/iOKbUCZotj"

# Cleaning
Clean_timelines = {}
for i in range(len(names)):
    tmp = []
    for j in range(len(timelines[i])):
        tmp.extend([rm_pun(word1) for word1 in [clean(word) for word in timelines[i][j]['text'].split() if word] if word1])
    Clean_timelines[names[i]] = tmp
[rm_pun(word1) for word1 in [clean(word) for word in tweet.split() if word] if word1]

# Find the most frequent word
All_in_list=[]
for movie in names:
    All_in_list.extend(Clean_timelines[movie])

Counter([word for word in All_in_list if len(word)>4]).most_common()


