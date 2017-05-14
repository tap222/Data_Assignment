import os
import json
import pandas as pd
df = pd.io.json.json_normalize(pd.Series(open('ggevent.json').readlines()).apply(json.loads))
df['bottle.timestamp'] = pd.to_datetime(df['bottle.timestamp'], errors='coerce')
df.columns = ['gameid','timestamp','ai5','debug','random','mobile_vesion','eventtype','ts']
del df['debug']
del df['random']
df.head(2)
df.to_csv("Features.csv", index=False)
