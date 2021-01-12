from bs4 import BeautifulSoup
from urllib.request import urlopen
from urllib.error import URLError, HTTPError

def getCamerasPages(url):
    failed = False 
    i = 1
    video_hrefs = []

    while True:
        result_url = url if i < 2 else url + str(i) + "/"
        i += 1
        try:
            html = urlopen(result_url)
        except HTTPError as e:
            break
            
        soup = BeautifulSoup(html.read())
        div = soup.find("div", {"id": "cam-listing"})
        lis = soup.find_all("li", {"class": "cam_card"})
        for tag in lis:
            if len(tag.findAll("span", {"class": "cam-on"})) > 0:
                video_hrefs.append("https://www.geocam.ru" + tag.find_all('a', href=True)[0]['href'])
    
    return video_hrefs


def getYoutubeSrcAndGeomap(url):
    try:
        html = urlopen(url)
        soup = BeautifulSoup(html.read())
        youtubeSrc = soup.find("div", {"id": "player"}).find("iframe")["src"]
        youtubeSrc = youtubeSrc[:youtubeSrc.find("?")]
        geomapSrc = soup.find("div", {"id": "section-map-img"}).find("script").string
        geomapSrc = geomapSrc[geomapSrc.find("\"")+1:]
        geomapSrc = geomapSrc[:geomapSrc.find("\"")]
    except Exception:
        return None
    else:
        return {"video_link": youtubeSrc, "geolaction": geomapSrc}

def getAllCameras(url):
    res = []
    pages = getCamerasPages(url)
    for page in pages:
        link = getYoutubeSrcAndGeomap(page)
        if link is not None:
            res.append(getYoutubeSrcAndGeomap(page))
    return res

url = "https://www.geocam.ru/in/st-petersburg"
#print(getCamerasPages(url))
url = "https://www.geocam.ru/online/admiral-emb/"
#print(getYoutubeSrcAndGeomap(url))
url = "https://www.geocam.ru/in/st-petersburg/"
## print(getAllCameras(url))