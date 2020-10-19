from bs4 import BeautifulSoup
import requests as req
from bs4 import Comment
import pandas as pd
import numpy as np

# Получение данных по каждой игре

codes = pd.read_csv("../csvs/oct.csv")
list = codes.values.tolist()
cod = []
for i in list:
    cod.append(i[1])

df = pd.DataFrame()
for i in cod:
    resp = req.get("https://www.basketball-reference.com/boxscores/" + i + ".html")
    soup = BeautifulSoup(resp.text, 'html.parser')
    tables = soup.findAll('table')

    l = []
    row = []
    for table in tables:
        table_rows = table.find_all('tr')
        for tr in table_rows:
            th = tr.find_all('th')[0].text
            if th == "Team Totals":
                if row != [i.text for i in tr.find_all('td')]:
                    td = tr.find_all('td')
                    row = [i.text for i in td]
                    l.append(row)

    big = sum(l, [])

    l = []

    for comment in soup.find_all(text=lambda text: isinstance(text, Comment)):
        if comment.find("<table ") > 0:
            comment_soup = BeautifulSoup(comment, 'html.parser')
            table = comment_soup.find("table")
            table_rows = table.find_all('tr')
            for tr in table_rows:
                td = tr.find_all('td')
                row = [tr.text for tr in td]
                l.append(row)

    small = l[4:6] + l[8:]
    small = (sum(small, []))

    all = big + small
    df1 = pd.DataFrame([all])
    df = df.append(df1)
print(df)
df.to_csv("../csvs/2020season.csv", index=False, header=True)
