from bs4 import BeautifulSoup
import requests as req
from bs4 import Comment
import pandas as pd
import numpy as np


data = pd.read_csv("../csvs/dates--h-v.csv", parse_dates=["GDate"])
short = data
short["Start"]=short.iloc[0,2]

short["Diff"] = (short["GDate"] - short["Start"]).dt.days
print(short.head())
short["Home_changes"] = 0
short["Away_changes"] = 0
print(short.head())
print(len(short))
for i in range(len(short)):
    a = -1
    b=-1
    g=[]
    for j in range(i, 0, -1):
        if (short.iloc[j, 3] == short.iloc[i, 3] or short.iloc[j, 4] == short.iloc[i, 3]) and ((short.iloc[i, 6] - short.iloc[j, 6]) <= 7):
            h = (short.iloc[j, 1])
            g.append(j)
    print(i)
    print(g)
    team_list=[]
    final = 0
    if(len(g)) <= 1:
        short.iloc[i, 7] = 0
    else:
        for k in range(len(g)):
            home = short.iloc[g[k], 3]
            team_list.append(home)
        for z in range(len(team_list) -1):
            if team_list[z+1] != team_list[z]:
                final = final + 1
    print(team_list)
    #print(final)
    short.iloc[i, 7] = final


for i in range(len(short)):
    a = -1
    b=-1
    g=[]
    for j in range(i, 0, -1):
        if (short.iloc[j, 3] == short.iloc[i, 4] or short.iloc[j, 4] == short.iloc[i, 4]) and ((short.iloc[i, 6] - short.iloc[j, 6]) <= 7):
            h = (short.iloc[j, 1])
            g.append(j)
    #print(i)
    #print(g)
    team_list=[]
    final = 0
    if(len(g)) <= 1:
        short.iloc[i, 8] = 0
    else:
        for k in range(len(g)):
            home = short.iloc[g[k], 3]
            team_list.append(home)
        for z in range(len(team_list) -1):
            if team_list[z+1] != team_list[z]:
                final = final + 1
    #print(team_list)
    #print(final)
    short.iloc[i, 8] = final

print(short)
short.to_csv('../csvs/CHANGES_2020.csv', index = False, header=True)