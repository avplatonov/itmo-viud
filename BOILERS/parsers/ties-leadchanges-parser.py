from bs4 import BeautifulSoup
import requests as req
from bs4 import Comment
import pandas as pd
import numpy as np

# Подсчет количества "ничьих" по очкам  и смен лидера во время игры

codes = pd.read_csv("../csvs/oct.csv")
list = codes.values.tolist()
cod = []
for i in list:
    cod.append(i[1])
df = pd.DataFrame()
for i in cod:
    a = []
    resp = req.get("https://www.basketball-reference.com/boxscores/pbp/" + i + ".html")
    soup = BeautifulSoup(resp.text, 'html.parser')
    tables = soup.findAll('table')
    for comment in soup.find_all(text=lambda text: isinstance(text, Comment)):
        if comment.find("<table ") > 0:
            comment_soup = BeautifulSoup(comment, 'html.parser')
            table = comment_soup.find("table")
            table_rows = table.find_all('tr')
            for tr in table_rows:
                th = tr.find_all('th')
                for t in th:
                    if t.text == "Ties":
                        td = tr.find_all('td')
                        a.append(td[0].text)
                for t in th:
                    if t.text == "Lead changes":
                        td = tr.find_all('td')
                        a.append(td[0].text)
    df1 = pd.DataFrame([a])
    df = df.append(df1)
print(df)
df.to_csv("../csvs/2020seasonties.csv", index=False, header=True)
