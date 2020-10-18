from bs4 import BeautifulSoup
import requests as req
from bs4 import Comment
import pandas as pd
import numpy as np

codes = pd.read_excel("../csvs/legends_GOGA.xlsx")
list = codes.values.tolist()
first_legend = []
second_legend = []
for i in list:
    first_legend.append(i[1])
    second_legend.append(i[2])

df = pd.DataFrame()

codes = pd.read_csv("../csvs/legend.csv")
list = codes.values.tolist()
list2 = list[0:4]
for i in list:
    a = []
    l = [0, 0, "YES", "YES"]
    m = [0, 0, "YES", "YES"]
    resp = req.get("https://www.basketball-reference.com/boxscores/" + i[1] + ".html")
    soup = BeautifulSoup(resp.text, 'html.parser')
    table_visitor = soup.findAll('table', id="box-" + i[2] + "-game-basic")
    table_home = soup.findAll('table', id="box-" + i[3] + "-game-basic")
    for table in table_visitor:
        table_rows = table.find_all('tr')
        for tr in table_rows:
            th = tr.find_all('th')[0].text
            if th in first_legend:
                td = tr.find_all('td')
                l[0] = td[0].text

    for table in table_visitor:
        table_rows = table.find_all('tr')
        for tr in table_rows:
            th = tr.find_all('th')[0].text
            if th in second_legend:
                td = tr.find_all('td')
                l[1] = td[0].text

    if l[0] == 0:
        l[2] = "NO"
    if l[1] == 0:
        l[3] = "NO"

    for table in table_home:
        table_rows = table.find_all('tr')
        for tr in table_rows:
            th = tr.find_all('th')[0].text
            if th in first_legend:
                td = tr.find_all('td')
                m[0] = td[0].text

    for table in table_home:
        table_rows = table.find_all('tr')
        for tr in table_rows:
            th = tr.find_all('th')[0].text
            if th in second_legend:
                td = tr.find_all('td')
                m[1] = td[0].text

    if m[0] == 0:
        m[2] = "NO"
    if m[1] == 0:
        m[3] = "NO"

    a = l + m
    df1 = pd.DataFrame([a])
    df = df.append(df1)
print(df)
df.to_csv('../csvs/2020season_legends_GOGA_EDITION.csv', index=False, header=True)
