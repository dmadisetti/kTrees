import MySQLdb
import pandas as pd
import enchant
from textblob import TextBlob

d = enchant.Dict("en_US")
db = MySQLdb.connect(host="172.17.42.1",user="garbageman",passwd="HUDMFr3jR4SmuLer",db="dropcan")
c = pd.read_sql("select * from dropcan", con=db)

df = pd.DataFrame(index=c.index,columns=['count','uniques','good','sentiment','subjectiveness'])

for i, row in c.iterrows():
    words = c.loc[i, 'memo'].split()

    if len(words) == 0:
        continue

    uniques = set(words)
    good = 0

    try:
        sentiment = TextBlob(c.loc[i, 'memo']).sentiment
        df.loc[i, 'sentiment'] = sentiment[0]
        df.loc[i, 'subjectiveness'] = sentiment[1]
    except:
        continue

    for unique in uniques:
        try:
            good += [0,1][d.check(unique)]
        except:
            continue

    df.loc[i, 'uniques'] = len(uniques)
    df.loc[i, 'count']   = len(words)
    df.loc[i, 'good']    = good

df.to_csv("processed.csv", sep=',')

for i, row in c.iterrows():
    # Cap at 2000, otherwise bitch in memory
    c.loc[i, 'memo'] = c.loc[i, 'memo'][:2000].replace('\n', ' ').replace('\r', '')

c.to_csv("quotes.csv", sep=',',columns=['memo'])