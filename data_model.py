import pandas as pd
import datetime
import os
from subprocess import check_output
from datetime import timedelta
print(check_output(["ls"]).decode("utf8"))
df = pd.read_csv('Features.csv',low_memory = False)
df.shape
df.info
df['timestamp'] = pd.to_datetime(df['timestamp'])
cnt_val= 0
cnt_inval= 0
cnt_mul_ses = 0
avg_time=[]
gameid=[]
st = pd.DataFrame()
time = pd.DataFrame()
game_ttl=[]
game_non_cons=[]
for i in range(len(df)-1):
    row1, row2 = df.ix[i], df.ix[i+1]
    if((row2['ai5']==row1['ai5']) and row2['gameid']==row1['gameid']):  
          if (row1['eventtype'] == 'ggstart' and row2['eventtype']== 'ggstop'):
                 if (row2['timestamp']- row1['timestamp']) >= timedelta(minutes=1): 
                      gameid.append(row2['gameid'])
                      avg_time.append(row2['timestamp']- row1['timestamp'])               
                      cnt_val += 1
                 elif (row2['timestamp']- row1['timestamp']) >= timedelta(seconds=30):
                      gameid.append(row2['gameid'])
                      avg_time.append(row2['timestamp']- row1['timestamp'])
                      cnt_mul_ses+=1
                 elif (row2['timestamp']-row1['timestamp']) < timedelta(seconds=30):
                      game_ttl.append(row2['gameid'])
                      cnt_inval += 1
          elif (row1['eventtype'] == 'ggstart' and row2['eventtype']== 'ggstart'):
                    game_ttl.append(row2['gameid'])
                    cnt_inval += 1
    else:
        continue
print('Valid session:',cnt_val)
print('invalid session:',cnt_inval)
print('multiple session:',cnt_mul_ses)
st = pd.DataFrame(gameid,columns=['gameid'])
time = pd.DataFrame(avg_time,columns=['time'])
inval_game = pd.DataFrame(game_ttl,columns=['gameid'])
comb = pd.concat([st,time],axis=1)
print('Avg of time for valid games')
comb['time'] = pd.to_timedelta(combined['time'])
grp = comb.groupby(comb['gameid'])
print(grp['time'].sum()/grp['time'].count())
