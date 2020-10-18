from bs4 import BeautifulSoup
from urllib.request import Request, urlopen
import csv

links = ["https://www.basketball-reference.com/leagues/NBA_2020_games-october.html",
         "https://www.basketball-reference.com/leagues/NBA_2020_games-november.html",
         "https://www.basketball-reference.com/leagues/NBA_2020_games-december.html",
         "https://www.basketball-reference.com/leagues/NBA_2020_games-january.html",
         "https://www.basketball-reference.com/leagues/NBA_2020_games-february.html",
         "https://www.basketball-reference.com/leagues/NBA_2020_games-march.html"]

file = "../csvs/oct.csv"
with open(file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, delimiter=',')

    i = 0
    writer.writerow([i, "codes"])
    for link in links:
        req = Request(link,
                      headers={"User-Agent": "Mozilla/5.0"})  # обманка, иначе БАН
        soup = BeautifulSoup(urlopen(req).read(), "html.parser")
        box_scores = soup.find_all("td", {"data-stat": "box_score_text"})
        for box_score in box_scores:
            i += 1
            box_score_code = (box_score.findChildren("a")[0].get('href').split("/boxscores/")[1]).split(".html")[0]
            print(box_score_code)
            writer.writerow([i, box_score_code])
