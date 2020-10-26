import requests
from parsing_constants import *
from bs4 import BeautifulSoup

def get_star_rating(soup):
    starBlock = soup.find(class_ = starBlockClass)

    filledCount = len(starBlock.find_all(class_ = filledStarClass))

    partialFillPercent = round(float(starBlock.find(class_ = partialStarClass)["style"].split(":")[-1][0:-2])/100, 4)

    return filledCount + partialFillPercent

def get_score_bar_width(soup, barClass):
    return int(soup.find(class_ = barClass)["style"].split(":")[-1][0:-1])

def get_total_review_count(soup):
    return int("".join(str(soup.find(class_ = reviewCountClass).contents[0].contents[0]).split(',')))

def get_star_counts_and_accr(soup):
    barWidths = []
    barWidths.append(get_score_bar_width(soup, oneStarBarClass))
    barWidths.append(get_score_bar_width(soup, twoStarBarClass))
    barWidths.append(get_score_bar_width(soup, threeStarBarClass))
    barWidths.append(get_score_bar_width(soup, fourStarBarClass))
    barWidths.append(get_score_bar_width(soup, fiveStarBarClass))

    widthPointCount = get_total_review_count(soup) / sum(barWidths)

    results = {
        "oneCount": int(round(barWidths[0] * widthPointCount , 0)),
        "twoCount": int(round(barWidths[1] * widthPointCount , 0)),
        "threeCount": int(round(barWidths[2] * widthPointCount , 0)),
        "fourCount": int(round(barWidths[3] * widthPointCount , 0)),
        "fiveCount": int(round(barWidths[4] * widthPointCount , 0)),
        "accuracy": int(round(widthPointCount, 0))
    }

    return results


def get_page_data(appId):

    resultDict = {
    "id": "",
    "name": "",
    "description": "",
    "genre": "",
    "related_cluster_url": "",
    "reviews": {
        "count": 0,
        "total_score": 0,
        "five_star_count": 0,
        "four_star_count": 0,
        "three_star_count": 0,
        "two_star_count": 0,
        "one_star_count": 0,
        "accuracy": 0
        }
    }

    appPage = requests.get(appBaseString + appId)

    soup = BeautifulSoup(appPage.text, 'html.parser')

    resultDict['id'] = appId
    resultDict['name'] = soup.find(class_ = nameClass).get_text()
    resultDict['genre'] = soup.find(class_ = genreClass, itemprop="genre")["href"].split('/')[-1]
    resultDict['description'] = soup.find(jsname = descriptionJsname).prettify()
    resultDict['reviews']['count'] = get_total_review_count
    resultDict['reviews']['total_score'] = get_star_rating(soup)
    resultDict['related_cluster_url'] = soup.find(jslog = relatedLinkClass)["href"]
    results = get_star_counts_and_accr(soup)

    resultDict['reviews']['one_star_count'] = results['oneCount']
    resultDict['reviews']['two_star_count'] = results['twoCount']
    resultDict['reviews']['three_star_count'] = results['threeCount']
    resultDict['reviews']['four_star_count'] = results['fourCount']
    resultDict['reviews']['five_star_count'] = results['fiveCount']
    resultDict['reviews']['accuracy'] = results['accuracy']

    return resultDict
